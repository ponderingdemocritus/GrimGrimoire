// COPY PASTA BECAUSE VERSIONS

#[starknet::interface]
trait IBeasts<T> {
    fn getBeast(self: @T, token_id: u256) -> PackableBeast;
}

#[derive(Drop, Serde, Copy)]
struct PackableBeast {
    id: u8, // 7 bits in storage
    prefix: u8, // 7 bits in storage
    suffix: u8, // 5 bits in storage
    level: u16, // 16 bits in storage
    health: u16, // 16 bits in storage
}
