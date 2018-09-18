# DynamicDispatch

Are you injecting dependencies on test time? Are you using [Mox]? Do you miss dialyzer when doing
something like `dependency().do_something()`?

This libs solves this problem by automatically implementing a module that fetches the implementation
in runtime but also implements all the methods of a behaviour without you doing anything.

```elixir
defmodule MyApp.Repo do
  use DynamicDispatch,
    for: Ecto.Repo,
    to: Application.get_env(:my_app, :repo, MyApp.Repo.DefaultImpl)
end

defmodule MyApp.Repo.DefaultImpl do
  use Ecto.Repo, otp_app: :repo
end
```

If you don't set the config `:my_app, :repo` to anything, all `Ecto.Repo` methods will be delegated
to MyApp.Repo.DefaultImpl, so it will work normally.

But if you want, in some test, to mock the Repo, you can do so by using [Mox] and this:

```elixir
Mox.defmock(MyApp.Repo.MockedImpl, for: Ecto.Repo)
Application.put_env(:my_app, :repo, MyApp.Repo.MockedImpl)
```

Now, all calls to `MyApp.Repo` will be dispatched to `MyApp.Repo.MockedImpl` and you can do your
`Mox.expect`/`Mox.stub` as usual.

## Installation

The package can be installed by adding `dynamic_dispatch` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:dynamic_dispatch, "~> 0.1.0"}
  ]
end
```

Documentation can be found at
[https://hexdocs.pm/dynamic_dispatch](https://hexdocs.pm/dynamic_dispatch).

## Credits

This lib was inspired by [this talk from Aaron Renner](https://www.youtube.com/watch?v=Ue--hvFzr0o).

We were already doing some kind of dynamic dispatching but we were having some problems with
dialyzer, this talk however, gave us some ideas on how to do Dynamic Dispatching while keeping
dialyzer happy, but it required a lot of boilerplate so we came up with this idea.

So the main credits here are:

- @aaronrenner for the talk
- @polvalete for the macro idea