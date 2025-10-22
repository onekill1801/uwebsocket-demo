# ws_server.exs
# Chạy: elixir ws_server.exs
# Kết nối: ws://localhost:4000/ws

Mix.install([
  {:plug_cowboy, "~> 2.7"}
])

defmodule WsHandler do
  @behaviour :cowboy_websocket

  # Bước 1: upgrade từ HTTP -> WebSocket
  def init(req, _state) do
    {:cowboy_websocket, req, %{}}
  end

  # Bước 2: khi kết nối WebSocket khởi tạo
  def websocket_init(state) do
    IO.puts("✅ WebSocket connected")
    {:ok, state}
  end

  # Bước 3: nhận message text từ client
  def websocket_handle({:text, msg}, state) do
    IO.puts("📩 Received: #{msg}")
    reply = "Echo: #{msg}"
    {:reply, {:text, reply}, state}
  end

  # Bước 4: khi client ngắt kết nối
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
    # ✅ Cú pháp đúng: {handler, arg, opts_map}
    Plug.Conn.upgrade_adapter(conn, :websocket, {WsHandler, %{}, %{}})
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end

# Chạy server
{:ok, _} = Plug.Cowboy.http(WsRouter, [], port: 4000)
IO.puts("🚀 WebSocket server running at ws://localhost:4000/ws")

Process.sleep(:infinity)
