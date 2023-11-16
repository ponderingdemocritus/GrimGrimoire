mod packing;

use beasts::packing::BountyListing;

#[starknet::interface]
trait IBounty<TContractState> {
    fn add_bounty(ref self: TContractState, bounty: BountyListing);
    fn claim_bounty(ref self: TContractState, bounty_id: u16);
}

#[starknet::contract]
mod Bounty {
    use super::IBounty;
    use beasts::packing::BountyListing;

    use core::{
        array::{SpanTrait, ArrayTrait}, integer::u256_try_as_non_zero, traits::{TryInto, Into},
        clone::Clone, poseidon::poseidon_hash_span, option::OptionTrait, box::BoxTrait,
        starknet::{
            get_caller_address, ContractAddress, ContractAddressIntoFelt252, contract_address_const,
            get_block_timestamp, info::BlockInfo
        },
    };

    #[storage]
    struct Storage {
        bounty: LegacyMap::<felt252, BountyListing>,
        beasts_address: ContractAddress,
        lords_address: ContractAddress,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, _beasts_address: ContractAddress, _lords_address: ContractAddress
    ) {
        self.beasts_address.write(_beasts_address);
        self.lords_address.write(_lords_address);
    }

    #[external(v0)]
    impl Bounty of IBounty<ContractState> {
        fn add_bounty(ref self: ContractState, bounty: BountyListing) {}
        fn claim_bounty(ref self: ContractState, bounty_id: u16) {}
    }
}
