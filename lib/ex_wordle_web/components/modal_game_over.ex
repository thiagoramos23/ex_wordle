defmodule ExWordleWeb.ModalGameOver do
  use Phoenix.Component
  import ExWordleWeb.CoreComponents

  alias ExWordle.GameEngine

  attr :id, :string, required: true
  attr :show, :boolean, required: true
  attr :game, GameEngine, required: true

  def show(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      class="relative z-10 hidden"
      aria-labelledby="modal-title"
      role="dialog"
      aria-modal="true"
    >
      <div
        id={"#{@id}-bg"}
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
        aria-hidden="true"
      >
      </div>

      <div class="fixed inset-0 z-10 overflow-y-auto">
        <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
          <div class="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl sm:my-8 sm:w-full sm:max-w-sm sm:p-6">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-mounted={@show && show_modal(@id)}
              class="transition"
            >
              <%= if GameEngine.win?(@game) do %>
                <.win />
              <% else %>
                <.loose />
              <% end %>
            </.focus_wrap>
            <div class="mt-5 sm:mt-6"></div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def win(assigns) do
    ~H"""
    <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-green-100">
      <svg
        class="h-6 w-6 text-green-600"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        aria-hidden="true"
      >
        <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5" />
      </svg>
    </div>
    <div class="mt-3 text-center sm:mt-5">
      <h3 class="text-base font-semibold leading-6 text-gray-900" id="modal-title">
        Congratulations! You won today!
      </h3>
      <div class="mt-2">
        <p class="text-sm text-gray-500">
          Come back tomorrow for a new adventure!
        </p>
      </div>
    </div>
    """
  end

  def loose(assigns) do
    ~H"""
    <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-red-100">
      <svg
        class="h-6 w-6"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        aria-hidden="true"
      >
        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
      </svg>
    </div>
    <div class="mt-3 text-center sm:mt-5">
      <h3 class="text-base font-semibold leading-6 text-gray-900" id="modal-title">
        I am so sorry! Nevermind, tomorrow you can try again!
      </h3>
      <div class="mt-2">
        <p class="text-sm text-gray-500">
          Tomorrow is a new day and a new challenge is waiting for you!
        </p>
      </div>
    </div>
    """
  end
end
