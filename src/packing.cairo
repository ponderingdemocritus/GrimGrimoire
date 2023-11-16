#[derive(Drop, Copy, Serde)]
struct BountyListing {
    bounty_id: u16, // Unique id
    beast: u8, // beast id
    bounty: u128, // Amount of Lords tokens for bounty
    prefix: u8, // 0 if no prefix
    suffix: u8, // 0 if no suffix
    expiration: u64, // Timestamp
    active: bool, // Is the bounty active
}
// impl PackPos3 of starknet::StorePacking<BountyListing, felt252> {
//     fn pack(value: Pos3) -> felt252 {
//         (value.x.into() + value.y.into() * SHIFT + value.z.into() * SHIFT * SHIFT)
//     }

//     fn unpack(value: felt252) -> Pos3 {
//         let value: u256 = value.into();
//         let shift: NonZero<u256> = integer::u256_try_as_non_zero(SHIFT.into()).unwrap();
//         let (rest, x) = integer::u256_safe_div_rem(value, shift);
//         let (z, y) = integer::u256_safe_div_rem(rest, shift);

//         Pos3 { x: x.try_into().unwrap(), y: y.try_into().unwrap(), z: z.try_into().unwrap() }
//     }
// }

