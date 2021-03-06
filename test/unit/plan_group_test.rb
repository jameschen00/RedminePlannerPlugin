# == Schema Information
#
# Table name: plan_groups
#
#  id           :integer          not null, primary key
#  project_id   :integer          default(0), not null
#  name         :string(255)      not null
#  group_type   :integer          not null
#  leader_id    :integer
#  parent_group :integer
#

require File.dirname(__FILE__) + '/../test_helper'

class PlanGroupTest < ActiveSupport::TestCase
  include Redmine::I18n

  fixtures :projects, :users, :plan_groups, :plan_group_members

  test "all_project_groups project 1" do
    project = Project.find(1)
    filtered = PlanGroup.all_project_groups(project)
    assert_equal 2, filtered.length
    assert_equal 1, filtered[0].project_id
    assert_equal 1, filtered[1].project_id
  end

  test "all_project_groups project 2" do
    filtered = PlanGroup.all_project_groups(2)
    assert_equal 1, filtered.length
    assert_equal 2, filtered[0].project_id
  end

  test "type_string i18n for team" do
    tmp = PlanGroup.new
    tmp.group_type = PlanGroup::TYPE_TEAM
    assert_equal l(:label_planner_group_team), tmp.type_string
  end

  test "type_string i18n for group" do
    tmp = PlanGroup.new
    tmp.group_type = PlanGroup::TYPE_GROUP
    assert_equal l(:label_planner_group_group), tmp.type_string
  end

  test "create new" do
    tmp = PlanGroup.new(
      :project => Project.find(1), :name => 'New team',
      :group_type => PlanGroup::TYPE_TEAM, :team_leader => User.find(2))
    assert tmp.save
  end

  test "validations" do
    # duplicate name for project 1, invalid group_type
    tmp = PlanGroup.new(
      :project => Project.find(1), :name => 'Team 1', :group_type => 7, :team_leader => User.find(2))
    assert !tmp.valid?
    assert tmp.errors[:name]
    assert tmp.errors[:group_type]
  end

  test "find teamleader" do
    leader = PlanGroup.find_teamleader(User.find(2))
    assert_equal User.find(1), leader
  end

  test "scope teams" do
    PlanGroup.teams.each do |team|
      assert_equal PlanGroup::TYPE_TEAM, team.group_type
    end
  end

  test "scope groups" do
    PlanGroup.groups.each do |group|
      assert_equal PlanGroup::TYPE_GROUP, group.group_type
    end
  end

  test "delete dependent" do
    tmp = PlanGroup.find(1)
    assert tmp.plan_group_members.any?
    tmp.destroy

    members = PlanGroupMember.where(:plan_group_id => 1)
    assert members.empty?
  end
end
