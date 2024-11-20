defmodule Slax.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer(),
          inserted_at: DateTime.t(),
          name: String.t(),
          topic: String.t(),
          updated_at: DateTime.t()
        }

  schema "rooms" do
    field :name, :string
    field :topic, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :topic])
    |> validate_required(:name)
    |> validate_length(:name, max: 80)
    |> validate_format(:name, ~r/\A[a-z0-9-]+\z/,
      message: "can only contain lowercase letters, numbers, and dashes"
    )
    |> validate_length(:topic, max: 200)
  end
end
