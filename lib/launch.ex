defmodule Launch do
  @moduledoc """
  Documentation for `Launch`.
  """

  @doc """
  """
  def start() do
    children = [
      %{
        id: Launch,
        start: {Launch, :launch, []}
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def launch() do
    spawn_link(Proc1, :start, [])
    spawn_link(Proc2, :start, [])

    Supervisor.start_link([%{id: Print, start: {Print, :print, []}}], strategy: :one_for_all)

    IO.puts("Restart!")

    launch()
  end
end


defmodule Print do
  def print() do
    num =
      IO.gets("Input number: ")
      |> String.trim()
      |> String.to_integer()

    cond do
      num > 0 -> 
        send(Proc1, {self(), num})

      num < 0 -> 
        send(Proc2, {self(), num})

      num == 0 -> 
        send(Proc1, {self(), num})
        send(Proc2, {self(), num})
    end

    receive do
      num -> IO.puts(num)
    after
      500 ->
        Process.exit(Process.whereis(Launch.Supervisor), :kill)
    end
    print()
  end
end


defmodule Proc1 do
  def start() do
    children = [
      %{
        id: Proc1,
        start: {Proc1, :proc1, []}
      }
    ]

  Supervisor.start_link(children, strategy: :one_for_one, name: Proc1)
  end

  def proc1() do
    receive do
      {pid, num} ->
        send(pid, 100/num)
        proc1()
      _e ->
        IO.puts("Error")
    end
  end
end


defmodule Proc2 do
  def start() do
    children = [
      %{
        id: Proc2,
        start: {Proc2, :proc2, []}
      }
    ]

  Supervisor.start_link(children, strategy: :one_for_one, name: Proc2)
  end

  def proc2() do
    receive do
      {pid, num} ->
        send(pid, 1000/num)
        proc2()
      _e ->
        IO.puts("Error")
    end
  end
end
