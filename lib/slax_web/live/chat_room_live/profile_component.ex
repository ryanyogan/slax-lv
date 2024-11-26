defmodule SlaxWeb.ChatRoomLive.ProfileComponent do
  use SlaxWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="flex flex-col flex-shrink-0 w-1/4 max-w-xs bg-white shadow-xl">
      <div class="flex items-center h-16 border-b border-slate-300 px-4">
        <div>
          <h2 class="text-lg font-bold text-gray-800">Profile</h2>
        </div>
        <button
          phx-click="close-profile"
          class="flex items-center justify-center size-6 rounded hover:bg-gray-300 ml-auto"
        >
          <.icon name="hero-x-mark" class="size-5" />
        </button>
      </div>
      <div class="flex flex-col flex-grow overflow-auto px-4">
        <div class="mb-4">
          <img src={~p"/images/one_ring.jpg"} class="w-48 rouded mx-auto" />
        </div>
        <h2 class="text-xl font-bold text-gray-800">
          <%= @user.username %>
        </h2>
      </div>
    </div>
    """
  end
end
