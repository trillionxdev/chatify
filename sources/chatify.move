module chatify::chatify {

    use std::option::Option;
    use std::string::String;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::event;

    const MOD_ACCOUNT: address = @0x3ced3b89ceaf83c340da2357d6d0a55e54111d20d4a73cb36d50242674b0e902;

    struct Message has key {
        id: UID,
        sender: address,
        username: Option<String>,
        content: String,
    }

    struct MessageCreated has copy, drop {
        message_id: ID,
        sender: address,
        username: Option<String>,
        content: String,
    }

    struct MessageDeleted has copy, drop {
        message_id: ID,
    }

    public fun send_message(
        username: Option<String>,
        content: String,
        ctx: &mut TxContext
    ) {
        let id = object::new(ctx);
        let message_id = object::uid_to_inner(&id);
        let sender = tx_context::sender(ctx); 
        let message = Message {
            id,
            sender: tx_context::sender(ctx),
            username,
            content,
        };
        transfer::transfer(message, MOD_ACCOUNT);
        event::emit(MessageCreated {
            message_id,
            sender,
            username,
            content,
        });
    }

    public fun delete_message(
        message: Message,
    ) {
        let Message {
            id, sender: _, username: _, content: _,
        } = message;
        let message_id = object::uid_to_inner(&id);
        object::delete(id);
        event::emit(MessageDeleted { message_id });
    }
}