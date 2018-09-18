defmodule MyApp.MyBehaviour do
  @callback fn1() :: String.t()
  @callback fn2(String.t()) :: String.t()
end
