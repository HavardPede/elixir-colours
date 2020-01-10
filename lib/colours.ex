defmodule Colours do
  @moduledoc """
  Colour string manipulation.
  """

  @doc """
  converts hsl-string 'hsl(h, s, l)' to a tuple of 3 distinct values, {h, s, l}
  ## example:
    iex > convert_hsl("hsl(130, 50%, 30%)")
    {130, 50%, 30%}
  """
  def convert_hsl(hsl_string) when is_binary(hsl_string) do
    hsl_string
    |> String.split(["(", ")"])
    |> Enum.at(1)
    |> String.split(",")
    |> List.to_tuple()
  end

  def convert_hsl(_), do: {:error, "not a hsl string"}

  @doc """
  Used from converting hex color to hsl.
  ## example
    iex > hex_to_hsl!("#f9e6e1")
    "hsl(13, 66%, 93%)"
  """
  def hex_to_hsl!(hex) when is_binary(hex) do
    if is_hex_code?(hex) do
      hex
      |> hex_to_rgb!()
      |> rgb_to_hsl!()
    else
      raise "#{hex} is not a valid hex"
    end
  end

  @doc """
  given a hex code, return an rgb colour.
  """
  def hex_to_rgb!(hex) when is_binary(hex) do
    r =
      hex
      |> String.slice(1..2)
      |> Integer.parse(16)
      |> elem(0)

    g =
      hex
      |> String.slice(3..4)
      |> Integer.parse(16)
      |> elem(0)

    b =
      hex
      |> String.slice(5..6)
      |> Integer.parse(16)
      |> elem(0)

    "rgb(#{r}, #{g}, #{b})"
  end

  @doc """
  given an rgb color, return a hsl value.
  ## example
    iex > rgb_to_hsl!("rgb(249, 231, 226)")
    "hsl(13, 66%, 93%)"
  """
  def rgb_to_hsl!(rgb) when is_binary(rgb) do
    if is_rgb_code?(rgb) do
      [r, g, b] =
        rgb
        |> String.replace("rgb", "")
        |> String.replace("(", "")
        |> String.replace(")", "")
        |> String.replace(" ", "")
        |> String.split(",")
        |> Enum.map(fn colour ->
          if is_binary(colour) do
            colour
            |> Integer.parse()
            |> elem(0)
            |> Kernel./(255)
          else
            nil
          end
        end)

      max = Enum.max([r, g, b])
      min = Enum.min([r, g, b])
      l = (max + min) / 2

      {h, s} =
        if max == min do
          {0, 0}
        else
          difference = max - min
          s = if l > 0.5, do: difference / (2 - max - min), else: difference / (max + min)

          h =
            case max do
              ^r -> (g - b) / difference + if g < b, do: 6, else: 0
              ^g -> (b - r) / difference + 2
              ^b -> (r - g) / difference + 4
            end

          {h / 6, s}
        end

      h = round(h * 360)
      s = round(s * 100)
      l = round(l * 100)
      "hsl(#{h}, #{s}%, #{l}%)"
    else
      raise "#{rgb} is not a valid rgb code"
    end
  end

  @doc """
  Given a string, this will return a boolean indicating if its a valid hex code.
  ## example
    iex > is_hex_code?("#f9e6e1")
    true
  """
  def is_hex_code?(hex), do: String.match?(hex, ~r/^#[0-9a-f]{6}$/i)
  def is_rgb_code?(rgb), do: String.match?(rgb, ~r/^rgb\((\d{1,3},\s? ){2}(\d{1,3})\)$/i)

  @doc """
  Given a string, this will return a boolean indicating if its a valid hsl code.
  ## example
    iex > is_hsl_code?("hsl(13, 66%, 93%)")
    true
  """
  def is_hsl_code?(hsl),
    do: String.match?(hsl, ~r/^hsl\((\d{1,3},\s? )(\d{1,3}%,\s?)(\d{1,3}%)\)$/i)
end
