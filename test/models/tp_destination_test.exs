defmodule CgratesWebJsonapi.TpDestinationTest do
  use CgratesWebJsonapi.ModelCase

  alias CgratesWebJsonapi.TpDestination

  @valid_attrs %{prefix: "some content", tag: "some content", tpid: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = TpDestination.changeset(%TpDestination{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = TpDestination.changeset(%TpDestination{}, @invalid_attrs)
    refute changeset.valid?
  end
end
