require "test_helper"

class ParameterFilterTest < Minitest::Test
  def setup
    @filter = Lennarb::ParameterFilter.new
  end

  test "filters sensitive parameters" do
    params = {
      "user" => "john",
      "password" => "secret123",
      "email" => "john@example.com",
      "token" => "abc123"
    }

    filtered = @filter.filter(params)

    assert_equal "john", filtered["user"]
    assert_equal "[FILTERED]", filtered["password"]
    assert_equal "[FILTERED]", filtered["email"]
    assert_equal "[FILTERED]", filtered["token"]
  end

  test "filters nested parameters" do
    params = {
      "user" => {
        "name" => "john",
        "credentials" => {
          "password" => "secret123",
          "api_token" => "abc123"
        }
      }
    }

    filtered = @filter.filter(params)

    assert_equal "john", filtered["user"]["name"]
    assert_equal "[FILTERED]", filtered["user"]["credentials"]["password"]
    assert_equal "[FILTERED]", filtered["user"]["credentials"]["api_token"]
  end

  test "filters parameters in arrays" do
    params = {
      "users" => [
        {"name" => "john", "password" => "secret1"},
        {"name" => "jane", "password" => "secret2"}
      ]
    }

    filtered = @filter.filter(params)

    assert_equal "john", filtered["users"][0]["name"]
    assert_equal "[FILTERED]", filtered["users"][0]["password"]
    assert_equal "jane", filtered["users"][1]["name"]
    assert_equal "[FILTERED]", filtered["users"][1]["password"]
  end

  test "filters partial matches" do
    params = {
      "username" => "john",
      "user_password" => "secret",
      "confirmation_token" => "abc123",
      "credit_card_cvv" => "123",
      "secret_question" => "What is your pet's name?"
    }

    filtered = @filter.filter(params)

    assert_equal "john", filtered["username"]
    assert_equal "[FILTERED]", filtered["user_password"]
    assert_equal "[FILTERED]", filtered["confirmation_token"]
    assert_equal "[FILTERED]", filtered["credit_card_cvv"]
    assert_equal "[FILTERED]", filtered["secret_question"]
  end

  test "accepts custom filters" do
    custom_filter = Lennarb::ParameterFilter.new(["custom", "api_key"])

    params = {
      "username" => "john",
      "password" => "should not be filtered with custom filter",
      "custom_field" => "filtered",
      "api_key" => "xyz"
    }

    filtered = custom_filter.filter(params)

    assert_equal "john", filtered["username"]
    assert_equal "should not be filtered with custom filter", filtered["password"]
    assert_equal "[FILTERED]", filtered["custom_field"]
    assert_equal "[FILTERED]", filtered["api_key"]
  end

  test "accepts custom mask value" do
    params = {
      "password" => "secret",
      "token" => "abc123"
    }

    filtered = @filter.filter(params, mask: "[REDACTED]")

    assert_equal "[REDACTED]", filtered["password"]
    assert_equal "[REDACTED]", filtered["token"]
  end

  test "handles non-hash and non-array values" do
    params = {
      "id" => 123,
      "active" => true,
      "null_value" => nil,
      "float_value" => 3.14
    }

    filtered = @filter.filter(params)

    assert_equal params, filtered
  end

  test "returns a copy of the original parameters" do
    params = {"password" => "secret"}

    filtered = @filter.filter(params)

    assert_equal "secret", params["password"]
    assert_equal "[FILTERED]", filtered["password"]
    refute_equal params.object_id, filtered.object_id
  end
end
