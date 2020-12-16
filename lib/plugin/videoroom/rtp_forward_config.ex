defmodule Janus.Plugin.VideoRoom.RtpForwardConfig do
  @moduledoc """
  Struct with options provided when requesting rtp forward

  Contains following fields:
  - `:room` - unique ID of the room to join; required,
  - `:publisher_id` - unique ID of the publisher
  """

  alias Janus.Plugin.VideoRoom

  # @host_family :: :ipv4 | :ipv6

  @type t() :: %__MODULE__{
          room_id: VideoRoom.room_id(),
          publisher_id: String.t(),
          host: String.t(),
          # host_family: host_family() | nil,
          audio_port: non_neg_integer() | nil,
          audio_ssrc: non_neg_integer() | nil,
          audio_pt: non_neg_integer() | nil,
          audio_rtcp_port: non_neg_integer() | nil,
          video_port: non_neg_integer() | nil,
          video_ssrc: non_neg_integer() | nil,
          video_pt: non_neg_integer() | nil,
          video_rtcp_port: non_neg_integer() | nil,
          simulcast?: boolean() | nil,
          video_port_2: non_neg_integer() | nil,
          video_ssrc_2: non_neg_integer() | nil,
          video_pt_2: non_neg_integer() | nil,
          video_port_3: non_neg_integer() | nil,
          video_ssrc_3: non_neg_integer() | nil,
          video_pt_3: non_neg_integer() | nil,
          data_port: non_neg_integer() | nil,
          srtp_suite: non_neg_integer() | nil,
          srtp_crypto: String.t() | nil
        }

  @enforce_keys [:room_id, :publisher_id, :host]

  defstruct [
    # :host_family,
    :audio_port,
    :audio_ssrc,
    :audio_pt,
    :audio_rtcp_port,
    :video_port,
    :video_ssrc,
    :video_pt,
    :video_rtcp_port,
    :simulcast?,
    :video_port_2,
    :video_ssrc_2,
    :video_pt_2,
    :video_port_3,
    :video_ssrc_3,
    :video_pt_3,
    :data_port,
    :srtp_suite,
    :srtp_crypto
    | @enforce_keys
  ]

  @struct_to_janus_keys %{
    :room_id => :room,
    :publisher_id => :publisher_id,
    :host => :host,
    # :host_family => :host_family,
    :audio_port => :audio_port,
    :audio_ssrc => :audio_ssrc,
    :audio_pt => :audio_pt,
    :audio_rtcp_port => :audio_rtcp_port,
    :video_port => :video_port,
    :video_ssrc => :video_ssrc,
    :video_pt => :video_pt,
    :video_rtcp_port => :video_rtcp_port,
    :simulcast? => :simulcast,
    :video_port_2 => :video_port_2,
    :video_ssrc_2 => :video_ssrc_2,
    :video_pt_2 => :video_pt_2,
    :video_port_3 => :video_port_3,
    :video_ssrc_3 => :video_ssrc_3,
    :video_pt_3 => :video_pt_3,
    :data_port => :data_port,
    :srtp_suite => :srtp_suite,
    :srtp_crypto => :srtp_crypto
  }

  @spec to_janus_message(t()) :: map()
  def to_janus_message(configuration) do
    configuration
    |> Map.from_struct()
    |> Bunch.KVEnum.filter_by_values(&(&1 != nil))
    |> Bunch.KVEnum.map_keys(&Map.get(@struct_to_janus_keys, &1, &1))
    |> Map.new()
  end
end
