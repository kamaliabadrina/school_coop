require "test_helper"

class RegistrationBillsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @registration_bill = registration_bills(:one)
  end

  test "should get index" do
    get registration_bills_url
    assert_response :success
  end

  test "should get new" do
    get new_registration_bill_url
    assert_response :success
  end

  test "should create registration_bill" do
    assert_difference("RegistrationBill.count") do
      post registration_bills_url, params: { registration_bill: { amount: @registration_bill.amount, status: @registration_bill.status, user_id: @registration_bill.user_id } }
    end

    assert_redirected_to registration_bill_url(RegistrationBill.last)
  end

  test "should show registration_bill" do
    get registration_bill_url(@registration_bill)
    assert_response :success
  end

  test "should get edit" do
    get edit_registration_bill_url(@registration_bill)
    assert_response :success
  end

  test "should update registration_bill" do
    patch registration_bill_url(@registration_bill), params: { registration_bill: { amount: @registration_bill.amount, status: @registration_bill.status, user_id: @registration_bill.user_id } }
    assert_redirected_to registration_bill_url(@registration_bill)
  end

  test "should destroy registration_bill" do
    assert_difference("RegistrationBill.count", -1) do
      delete registration_bill_url(@registration_bill)
    end

    assert_redirected_to registration_bills_url
  end
end
