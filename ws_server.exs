# ws_server.exs
# Chạy: elixir ws_server.exs
# Kết nối: ws://localhost:4000/ws

Mix.install([
  {:plug_cowboy, "~> 2.7"}
])

defmodule WsHandler do
  @behaviour :cowboy_websocket

  # Khi HTTP request upgrade lên WebSocket
  def init(req, _state) do
    {:cowboy_websocket, req, %{}}
  end

  # Khi client kết nối thành công
  def websocket_init(state) do
    IO.puts("✅ WebSocket connected")
    {:ok, state}
  end

  # Khi nhận message từ client
  def websocket_handle({:text, msg}, state) do
    IO.puts("📩 Received: #{msg}")
    reply = "Echo: #{msg}"
    {:reply, {:text, reply}, state}
  end

  # Khi client ngắt kết nối
  def websocket_terminate(_reason, _state) do
    IO.puts("❌ Client disconnected")
    :ok
  end
end

defmodule WsRouter do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/ws" do
    Plug.Conn.upgrade_adapter(conn, :websocket, {WsHandler, %{}})
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end

# Chạy server
{:ok, _} = Plug.Cowboy.http(WsRouter, [], port: 4000)
IO.puts("🚀 WebSocket server running at ws://localhost:4000/ws")

Process.sleep(:infinity)
