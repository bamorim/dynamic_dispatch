defmodule MyApp.MyDispatcher do
  alias MyApp.MyBehaviour

  use DynamicDispatch,
    for: MyBehaviour,
    to: Application.get_env(:dynamic_dispatch, :impl)
end
