require "application_system_test_case"

class RegistrationBillsTest < ApplicationSystemTestCase
  setup do
    @registration_bill = registration_bills(:one)
  end

  test "visiting the index" do
    visit registration_bills_url
    assert_selector "h1", text: "Registration bills"
  end

  test "should create registration bill" do
    visit registration_bills_url
    click_on "New registration bill"

    fill_in "Amount", with: @registration_bill.amount
    fill_in "Status", with: @registration_bill.status
    fill_in "User", with: @registration_bill.user_id
    click_on "Create Registration bill"

    assert_text "Registration bill was successfully created"
    click_on "Back"
  end

  test "should update Registration bill" do
    visit registration_bill_url(@registration_bill)
    click_on "Edit this registration bill", match: :first

    fill_in "Amount", with: @registration_bill.amount
    fill_in "Status", with: @registration_bill.status
    fill_in "User", with: @registration_bill.user_id
    click_on "Update Registration bill"

    assert_text "Registration bill was successfully updated"
    click_on "Back"
  end

  test "should destroy Registration bill" do
    visit registration_bill_url(@registration_bill)
    click_on "Destroy this registration bill", match: :first

    assert_text "Registration bill was successfully destroyed"
  end
end
