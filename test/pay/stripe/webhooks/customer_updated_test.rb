require "test_helper"

class Pay::Stripe::Webhooks::CustomerUpdatedTest < ActiveSupport::TestCase
  setup do
    @pay_customer = pay_customers(:stripe)
  end

  test "removes default payment method if default payment method set to null" do
    event = stripe_event("customer.updated")
    Pay::Stripe::Billable.any_instance.expects(:customer).returns(OpenStruct.new(invoice_settings: OpenStruct.new(default_payment_method: nil)))
    assert_not_nil @pay_customer.default_payment_method
    Pay::Stripe::Webhooks::CustomerUpdated.new.call(event)
    @pay_customer.reload
    assert_nil @pay_customer.default_payment_method
  end

  test "stripe is not called if user can't be found" do
    event = stripe_event("customer.updated", overrides: {"object" => {"id" => "missing"}})
    Pay::Stripe::Billable.any_instance.expects(:sync_payment_method_from_stripe).never
    Pay::Stripe::Webhooks::CustomerUpdated.new.call(event)
  end
end
