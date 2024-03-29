# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Expected Version" do
  it "shouldn't allow to create following events, yet it is all green" do
    event_store = Rails.configuration.event_store

    event0 = Order::Changed.new(data: { some: :data })
    event_store.publish(
      event0,
      stream_name: "Order-1",
      expected_version: 1_000_000
    )

    event1 = Order::Changed.new(data: { some: :data })
    event_store.publish(
      event1,
      stream_name: "Order-1",
      expected_version: 2
    )

    event2 = Order::Changed.new(data: { some: :data })
    event_store.publish(
      event2,
      stream_name: "Order-1",
      expected_version: 5
    )

    client = Rails.configuration.event_store
    expect(client).to have_published(an_event(Order::Changed)).in_stream("Order-1").exactly(3).times # works!
  end

  specify "this would be the behavior I expect, yet the spec fails" do
    event_store = Rails.configuration.event_store
    event0 = Order::Changed.new(data: { some: :data })
    expect do
      event_store.publish(
        event0,
        stream_name: "Order-1",
        expected_version: 1_000_000
      )
    end.to raise_error(RubyEventStore::WrongExpectedEventVersion)
  end
end

