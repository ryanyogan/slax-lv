defmodule SlaxWeb.SocketHelpers do
  def ok(socket), do: {:ok, socket}

  def noreply(socket), do: {:noreply, socket}

  def reply(socket, reply), do: {:reply, reply, socket}
end
