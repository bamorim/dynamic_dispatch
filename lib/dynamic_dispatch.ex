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

        defp __dynamic_dispatch_impl__ do
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
            __dynamic_dispatch_impl__().unquote(fun)(unquote_splicing(args))
          end
        end
      )
    end
  end
end
