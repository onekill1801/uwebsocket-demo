defmodule EchoServer do
  use GenServer

  # --- Khởi động server ---
  def start_link(port) do
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  # --- Hàm khởi tạo ---
  def init(port) do
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [
        :binary,
        packet: :line,      # Nhận message theo dòng (kết thúc bằng \n)
        active: false,
        reuseaddr: true
      ])

    IO.puts("🚀 EchoServer listening on port #{port}")

    # Tạo tiến trình nhận kết nối
    spawn(fn -> accept_loop(listen_socket) end)

    {:ok, %{socket: listen_socket}}
  end

  # --- Vòng lặp chấp nhận kết nối ---
  defp accept_loop(listen_socket) do
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)
    IO.puts("✅ Client connected!")

    # Mở tiến trình riêng cho từng client
    spawn(fn -> handle_client(client_socket) end)

    # Tiếp tục chấp nhận kết nối mới
    accept_loop(listen_socket)
  end

  # --- Xử lý từng client ---
  defp handle_client(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        msg = String.trim(data)
        IO.puts("📩 Received: #{msg}")

        response = "Echo: #{msg}\n"
        :gen_tcp.send(socket, response)

        handle_client(socket)  # Lặp lại

      {:error, :closed} ->
        IO.puts("❌ Client disconnected.")
    end
  end
end

# --- Chạy server ---
{:ok, _pid} = EchoServer.start_link(4000)
Process.sleep(:infinity)
