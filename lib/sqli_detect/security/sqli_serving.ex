defmodule SQLiDetect.Security.SQLi do
  @moduledoc """
  The SQLi serving

  DISCLAIMER

  This module is _not_ the way to implement this.

  A singleton GenServer to handle event all LiveView event in an application
  will cause a bottle neck. I am completely aware what I am doing here is really
  bad. Also there is a subtle race condition in here, but it shouldn't effect
  local dev, so I am okay with it.

  I only do this because at the time of this writing this is the easiest way I
  know to pull the model and tokenizer, and then create the serving. After
  creating the serving, I want to store it for reuse.

  I think of some hypothetical ways to do this, but gives us enough for a prof
  of concept. I am defiantly open to feedback here.

  Some open questions:

  - Is there away to download the huggingface model and create the serving at
  compile time?
  - Do we want to do this?
  - Is runtime better?
  """

  use GenServer

  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def contains_sql_injection?(input) do
    GenServer.call(__MODULE__, {:contains_sql_injection?, input})
  end

  def init(_args) do
    {:ok, %{serving: nil}, {:continue, :make_serving}}
  end

  def handle_continue(:make_serving, state) do
    Logger.info("Downloading modal....")

    {:ok, model} =
      Bumblebee.load_model({:hf, "cybersectony/sql-injection-attack-detection-distilbert"})

    Logger.info("Downloading tokenizer....")

    {:ok, tokenizer} =
      Bumblebee.load_tokenizer({:hf, "cybersectony/sql-injection-attack-detection-distilbert"})

    Logger.info("Creating serving...")
    serving = Bumblebee.Text.text_classification(model, tokenizer)

    Logger.info("SQLi model ready")
    {:noreply, %{state | serving: serving}}
  end

  def handle_call({:contains_sql_injection?, input}, _from, state) do
    %{serving: serving} = state
    %{predictions: predictions} = Nx.Serving.run(serving, input)

    predicted = Enum.max_by(predictions, fn label -> label.score end)

    # for now just pick the label that has a higher score
    # this is naive, we can do better
    if predicted.label == "LABEL_0" do
      {:reply, false, state}
    else
      {:reply, true, state}
    end
  end
end
