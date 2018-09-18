defmodule DynamicDispatchTest do
  use ExUnit.Case

  alias MyApp.MyDispatcher

  test "It dispatches to the `for` evaluation in runtime" do
    Mox.expect(Impl1, :fn1, fn -> "Impl1" end)
    Mox.expect(Impl2, :fn1, fn -> "Impl2" end)
    Application.put_env(:dynamic_dispatch, :impl, Impl1)
    assert MyDispatcher.fn1() == "Impl1"
    Application.put_env(:dynamic_dispatch, :impl, Impl2)
    assert MyDispatcher.fn1() == "Impl2"
  end

  test "it generates all methods" do
    Mox.expect(Impl1, :fn1, fn -> "Impl1" end)
    Mox.expect(Impl1, :fn2, fn _ -> "Impl1" end)
    Application.put_env(:dynamic_dispatch, :impl, Impl1)
    assert MyDispatcher.fn1() == "Impl1"
    assert MyDispatcher.fn2("something") == "Impl1"
  end
end
