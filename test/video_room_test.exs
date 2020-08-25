defmodule Janus.Plugin.VideoRoomTest do
  use ExUnit.Case
  import Mock
  import VideoRoomTest.Helper
  alias Janus.Plugin.VideoRoom
  alias Janus.Plugin.VideoRoom.Errors

  @id 1
  @room_name "room_name"
  @handle_id 1

  describe "create_room/6 sends create room request through connection and" do
    test "returns ok tuple with room id on success" do
      description = "A room description"

      with_mock Janus.Session,
        execute_request: fn _, message ->
          assert message[:body][:room] == @room_name
          assert message[:body][:description] == description
          {:ok, %{"videoroom" => "created", "room" => @id}}
        end do
        room_props = %VideoRoom{description: description}

        assert {:ok, @id} ==
                 VideoRoom.create_room(Janus.Session, @room_name, room_props, nil, nil)
      end
    end

    test "returns an error when room already_exists" do
      code = Errors.code(:room_already_exists)

      with_mock Janus.Session,
        execute_request: fn _, _message ->
          {:ok, error_message(code)}
        end do
        assert {:error, Errors.error(code)} ==
                 VideoRoom.create_room(Janus.Session, @room_name, %VideoRoom{}, nil, nil)
      end
    end

    test_connection_error(&VideoRoom.create_room/5, [
      Janus.Session,
      @room_name,
      %VideoRoom{},
      nil,
      nil
    ])
  end

  describe "edit/5 sends edit room request through connection and" do
    test "returns ok tuple with room id on success" do
      with_mock Janus.Session,
        execute_request: fn _, message ->
          assert message[:body][:room] == @room_name
          assert message[:handle_id] == @handle_id
          assert message[:body][:request] == "edit"
          {:ok, %{"videoroom" => "edited", "room" => @id}}
        end do
        assert {:ok, @id} =
                 VideoRoom.edit(Janus.Session, @room_name, %VideoRoom{}, @handle_id, nil)
      end
    end

    test_no_such_room(&VideoRoom.edit/5, [
      Janus.Session,
      @room_name,
      %VideoRoom{},
      @handle_id,
      nil
    ])

    test_connection_error(&VideoRoom.edit/5, [
      Janus.Session,
      @room_name,
      %VideoRoom{},
      @handle_id,
      nil
    ])
  end

  describe "destroy/4 sends destroy room request through connection and" do
    test "returns ok tuple with room id on success" do
      with_mock Janus.Session,
        execute_request: fn _, message ->
          assert message[:body][:room] == @room_name
          assert message[:handle_id] == @handle_id
          assert message[:body][:request] == "destroy"
          {:ok, %{"videoroom" => "destroyed", "room" => @id}}
        end do
        assert {:ok, @id} = VideoRoom.destroy(Janus.Session, @room_name, @handle_id, nil)
      end
    end

    test_no_such_room(&VideoRoom.destroy/4, [Janus.Session, @room_name, @handle_id, nil])
    test_connection_error(&VideoRoom.destroy/4, [Janus.Session, @room_name, @handle_id, nil])
  end

  describe "exists/3 sends request checking if room exists through connection and" do
    test "returns ok tuple with boolean on success" do
      with_mock Janus.Session,
        execute_request: fn _, message ->
          assert message[:body][:room] == @room_name
          assert message[:handle_id] == @handle_id
          {:ok, %{"videoroom" => "success", "room" => @room_name, "exists" => true}}
        end do
        assert {:ok, true} = VideoRoom.exists(Janus.Session, @room_name, @handle_id)
      end
    end

    test_connection_error(&VideoRoom.exists/3, [Janus.Session, @room_name, @handle_id])
  end

  describe "list/2 sends list rooms request through connection and" do
    test "returns ok tuple with rooms list on success" do
      rooms = [%{"name" => "room1"}, %{"name" => "room2"}]

      with_mock Janus.Session,
        execute_request: fn _, message ->
          assert message[:handle_id] == @handle_id
          {:ok, %{"videoroom" => "success", "rooms" => rooms}}
        end do
        assert {:ok, rooms} == VideoRoom.list(Janus.Session, @handle_id)
      end
    end

    test_connection_error(&VideoRoom.list/2, [Janus.Session, @handle_id])
  end

  describe "allowed/6 sends request to updated allowed tokens through connection and" do
    setup do
      [allowed: ["a", "b", "c"]]
    end

    test "returns ok tuple with allowed list on success", %{allowed: allowed} do
      action = "add"

      with_mock Janus.Session,
        execute_request: fn _, message ->
          assert message[:body][:room] == @room_name
          assert message[:body][:action] == action
          assert message[:body][:allowed] == allowed
          assert message[:handle_id] == @handle_id
          {:ok, %{"videoroom" => "success", "room" => @room_name, "allowed" => allowed}}
        end do
        assert {:ok, allowed} ==
                 VideoRoom.allowed(Janus.Session, @room_name, action, allowed, @handle_id, nil)
      end
    end

    test_no_such_room(&VideoRoom.allowed/6, [
      Janus.Session,
      @room_name,
      "add",
      ["a", "b", "c"],
      @handle_id,
      nil
    ])

    test_connection_error(&VideoRoom.allowed/6, [
      Janus.Session,
      @room_name,
      "add",
      ["a", "b", "c"],
      @handle_id,
      nil
    ])
  end

  describe "kick/5 sends user kick request through connection and" do
    test "returns ok on success" do
      with_mock Janus.Session,
        execute_request: fn _, message ->
          assert message[:body][:room] == @room_name
          assert message[:handle_id] == @handle_id
          assert message[:body][:id] == "user_id"
          {:ok, %{"videoroom" => "success"}}
        end do
        assert :ok = VideoRoom.kick(Janus.Session, @room_name, "user_id", @handle_id, nil)
      end
    end

    test "returns error when user has not been found" do
      code = Errors.code(:no_such_feed)

      with_mock Janus.Session,
        execute_request: fn _, _message ->
          {:ok, error_message(code)}
        end do
        assert {:error, Errors.error(code)} ==
                 VideoRoom.kick(Janus.Session, @room_name, "user_id", @handle_id, nil)
      end
    end

    test_no_such_room(&VideoRoom.kick/5, [
      Janus.Session,
      @room_name,
      "user_id",
      @handle_id,
      nil
    ])

    test_connection_error(&VideoRoom.kick/5, [
      Janus.Session,
      @room_name,
      "user_id",
      @handle_id,
      nil
    ])
  end

  describe "list_participants/3 sends list participants request through connection and" do
    setup do
      [participants: [%{name: "participant1"}, %{name: "participant2"}]]
    end

    test "returns ok tuple with list of participants on success", %{participants: participants} do
      with_mock Janus.Session,
        execute_request: fn _, message ->
          assert message[:body][:room] == @room_name
          assert message[:handle_id] == @handle_id

          {:ok,
           %{"videoroom" => "participants", "room" => @room_name, "participants" => participants}}
        end do
        assert {:ok, participants} =
                 VideoRoom.list_participants(Janus.Session, @room_name, @handle_id)
      end
    end

    test_no_such_room(&VideoRoom.list_participants/3, [Janus.Session, @room_name, @handle_id])
    test_connection_error(&VideoRoom.list_participants/3, [Janus.Session, @room_name, @handle_id])
  end
end
