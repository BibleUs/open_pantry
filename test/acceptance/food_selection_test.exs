defmodule OpenPantry.FoodSelectionTest do
  use OpenPantry.AcceptanceCase, async: true
  import OpenPantry.Factory

  def complete_facility do
    facility = insert(:facility)
    user = insert(:user, facility: facility)
    food_group1 = insert(:food_group)
    food1 = insert(:food, food_group: food_group1)
    food_group2 = insert(:food_group)
    food2 = insert(:food, food_group: food_group2)
    stock1 = insert(:stock, facility: facility, food: food1)
    stock2 = insert(:stock, facility: facility, food: food2)
    credit_type1 = insert(:credit_type, food_groups: [food_group1])
    credit_type2 = insert(:credit_type, food_groups: [food_group2])
    insert(:user_credit, credit_type: credit_type1, user: user )
    insert(:user_credit, credit_type: credit_type2, user: user )
    %{credit_types: [credit_type1, credit_type2], facility: facility, user: user, stocks: [stock1, stock2], foods: [food1, food2], food_groups: [food_group1, food_group2]}
  end


  @tag timeout: Ownership.timeout
  test "selection table has tab per credit type, plus meals and cart", %{session: session} do
    %{credit_types: [credit_type|_]} = complete_facility()

    first_credit = session
    |> visit("/en/food_selections")
    |> find("##{credit_type.name}")
    |> text

    assert first_credit =~ ~r/#{credit_type.name}/
  end

  test "selection table shows first foods in stock on load", %{session: session} do
    %{credit_types: [credit_type|_], foods: [food|_]} = complete_facility()

    first_credit = session
    |> visit("/en/food_selections")
    |> find("##{credit_type.name}")
    |> text

    assert first_credit =~ ~r/#{food.longdesc}/
  end

  test "selection table does not show second food in stock on load", %{session: session} do
    %{credit_types: [credit_type|_], foods: [_|[food2]]} = complete_facility()

    first_credit = session
    |> visit("/en/food_selections")
    |> find("##{credit_type.name}")
    |> text

    refute first_credit =~ ~r/#{food2.longdesc}/
  end

  @tag timeout: Ownership.timeout
  test "selection table allows selecting second tab", %{session: session} do
    %{credit_types: [_|[credit_type2]], foods: [_|[food2]]} = complete_facility()

    second_credit = session
    |> visit("/en/food_selections")
    |> click_link(credit_type2.name)
    |> find("##{credit_type2.name}")
    |> text

    assert second_credit =~ ~r/#{food2.longdesc}/
  end
end