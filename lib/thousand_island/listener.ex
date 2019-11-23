defmodule ThousandIsland.Listener do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
  end

  def listener_socket(pid) do
    GenServer.call(pid, :listener_socket)
  end

  def init(opts) do
    transport_module = Keyword.get(opts, :transport_module, ThousandIsland.Transports.TCP)

    :telemetry.execute([:listener, :start], %{}, %{transport_module: transport_module})

    case transport_module.listen(opts) do
      {:ok, listener_socket} -> {:ok, %{listener_socket: listener_socket}}
      {:error, _} = error -> {:stop, error}
    end
  end

  def handle_call(:listener_socket, _from, %{listener_socket: listener_socket} = state) do
    {:reply, {:ok, listener_socket}, state}
  end
end
