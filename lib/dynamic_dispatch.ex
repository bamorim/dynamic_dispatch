defmodule DynamicDispatch do
  @moduledoc """
  Documentation for DynamicDispatch.
  """

  defmacro __using__(args \\ []) do
    impl_ast = Keyword.get(args, :to) || raise "You must provide a :to implementation"
    behaviour = Keyword.get(args, :for) || raise "You provide a :for behaviour"

    impl = Macro.escape(impl_ast)

    quote do
      DynamicDispatch.__setup_dispatcher__(__MODULE__, unquote(behaviour), unquote(impl))
    end
  end

  def __setup_dispatcher__(mod, behaviour, impl) do
    Module.eval_quoted(
      mod,
      quote do
        @behaviour unquote(behaviour)
      end
    )

    impl_count = (Module.get_attribute(mod, :__dynamic_dispatch_count__) || 0) + 1
    Module.put_attribute(mod, :__dynamic_dispatch_count__, impl_count)
    impl_name = :"__dynamic_dispatch_impl_#{impl_count}__"

    Module.eval_quoted(
      mod,
      quote do
        defp unquote(impl_name)() do
          unquote(impl)
        end
      end
    )

    for {fun, arity} <- behaviour.behaviour_info(:callbacks) do
      args = 0..arity |> Enum.to_list() |> tl() |> Enum.map(&Macro.var(:"arg#{&1}", Elixir))

      Module.eval_quoted(
        mod,
        quote do
          @impl unquote(behaviour)
          def unquote(fun)(unquote_splicing(args)) do
            unquote(impl_name)().unquote(fun)(unquote_splicing(args))
          end
        end
      )
    end
  end
end
