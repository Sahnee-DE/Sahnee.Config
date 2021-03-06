defmodule Sahnee.Config do
  default_otp = Application.compile_env(:sahnee_config, :default_otp)

  @moduledoc """
  Automatically creates an `env/1` function that allows to get a namespaced config value.
  All configuration values are resolved at runtime only.

  Options:

  - namespace: The namespace of the config values. Defaults to the calling module. Set to `nil` to disable namespacing
    and use global configuration values.
  - keys: A list of compile time atoms for which `env_<name>/0` functions will be generated to get the given config
    value. Serves as a way to statically declare all used values.
  - otp: The OTP app to get the values from. If not set the `:sahnee_config` `:default_otp` compile time config value is
    used.

  Example

      defmodule MyModule
        using Sahnee.Config, keys: [:value1, :value2]

        # Generates:

        defp env(key), do: Sahnee.Config.env(:your_app, key)
        defp env_value1(), do: env(:value1)
        defp env_value2(), do: env(:value2)
      end
  """

  @doc """
  Gets a runtime configuration value.
  """
  @compile {:inline, env: 2}
  @compile {:inline, env: 3}
  def env(otp, key, default \\ nil) do
    case Application.fetch_env(otp, key) do
      {:ok, value} -> value
      :error -> default
    end
  end

  defmacro __using__(opts \\ []) do
    keys = Access.get(opts, :keys, [])
    otp = Access.get(opts, :otp, unquote(default_otp))
    namespace = Access.get(opts, :namespace, __CALLER__.module)

    funs = for key <- keys do
      quote do
        @compile {:inline, [{:"env_#{unquote(key)}", 0}]}
        defp unquote(:"env_#{key}")() do
          env(unquote(key))
        end
      end
    end

    quote do
      @compile {:inline, env: 1}
      case unquote(namespace) do
        nil ->
          defp env(key), do: Sahnee.Config.env(unquote(otp), key)
        _ ->
          defp env(key), do: Sahnee.Config.env(unquote(otp), unquote(namespace))[key]
      end

      unquote funs
    end
  end
end
