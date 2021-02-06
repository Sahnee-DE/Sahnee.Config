# Sahnee.Config

Small helper library used inject a commonly used configuration pattern in projects at [Sahnee](https://sahnee.dev).

Our configurations are typically isolated by module, meaning that config values relevant for module `MyModule`
are set like:

```elixir
config :your_app, MyModule,
  value1: true,
  value2: "hello world"
```

This library allows us to seamlessly use these values in `MyModule`

```elixir
defmodule MyModule
  using Sahnee.Config, keys: [:value1, :value2]

  # Generates:
  defp env(key), do: Sahnee.Config.env(:your_app, key)
  defp env_value1(), do: env(:value1)
  defp env_value2(), do: env(:value2)
end
```

Allowing us to simply call the `env_value1/0` function whenever we need to access this value without having to repeat
the small, but quickly annoying boilerplate code.

## Limitations

By design this library only allows to resolve runtime configuration values by using `Application.fetch_env`.

## Installation

```elixir
def deps do
  [
    {:sahnee_config, "~> 0.1.0"}
  ]
end
```

Documentation can be be found at [https://hexdocs.pm/sahnee_config](https://hexdocs.pm/sahnee_config).

