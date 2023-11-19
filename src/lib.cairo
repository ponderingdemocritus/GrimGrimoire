mod packing;
mod interfaces;

use beasts::packing::BountyListing;

#[starknet::interface]
trait IBounty<TContractState> {
    fn add_bounty(ref self: TContractState, bounty: BountyListing);
    fn claim_bounty(ref self: TContractState, bounty_id: u16, beast_id: u256);
    fn cancel_bounty(ref self: TContractState, bounty_id: u16);
}

#[starknet::contract]
mod Bounty {
    use beasts::interfaces::IBeastsDispatcherTrait;
    use super::IBounty;
    use beasts::interfaces::{IBeasts, IBeastsDispatcher};
    use beasts::packing::BountyListing;

    use core::{
        array::{SpanTrait, ArrayTrait}, integer::u256_try_as_non_zero, traits::{TryInto, Into},
        clone::Clone, poseidon::poseidon_hash_span, option::OptionTrait, box::BoxTrait,
        starknet::{
            get_caller_address, ContractAddress, ContractAddressIntoFelt252, contract_address_const,
            get_block_timestamp, info::BlockInfo, get_contract_address
        },
    };

    use openzeppelin::token::erc20::erc20::ERC20;
    use openzeppelin::token::erc20::interface::{
        IERC20Camel, IERC20CamelDispatcher, IERC20CamelDispatcherTrait, IERC20CamelLibraryDispatcher
    };

    use openzeppelin::token::erc721::interface::{
        IERC721Dispatcher, IERC721DispatcherTrait, IERC721LibraryDispatcher
    };

    #[storage]
    struct Storage {
        bounty: LegacyMap::<felt252, BountyListing>, // bounty
        owner: LegacyMap::<felt252, ContractAddress>, // owner of bounty
        bounty_count: felt252,
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
        fn add_bounty(ref self: ContractState, bounty: BountyListing) {
            // get count
            let mut count = self.bounty_count.read();
            count += 1;

            // transfer value
            let lords_contract = IERC20CamelDispatcher {
                contract_address: self.lords_address.read(),
            };
            lords_contract.transfer(get_contract_address(), bounty.bounty.into());

            // TODO: check if beast exists
            assert(bounty.beast < 74, 'beast id out of range');
            assert(bounty.prefix < 74, 'prefix id out of range');
            assert(bounty.suffix < 74, 'suffix id out of range');

            // TODO: You have to pass in 1 when setting
            assert(bounty.active == 1, 'must pass in active bounty');

            // set bounty
            self.bounty.write(count, bounty);

            // set count
            self.bounty_count.write(count);

            // set owner of bounty
            self.owner.write(count, get_caller_address());
        }
        fn claim_bounty(ref self: ContractState, bounty_id: u16, beast_id: u256) {
            // get bounty
            let mut bounty = self.bounty.read(bounty_id.into());
            let bounty_owner = self.owner.read(bounty_id.into());

            // assert active
            assert(bounty.active == 1, 'bounty not active');

            // get beast
            let beast = IBeastsDispatcher { contract_address: self.beasts_address.read() }
                .getBeast(beast_id);

            // assert matching beast. TODO: other asserts
            assert(beast.id == bounty.beast, 'beast id does not match bounty');

            // transfer lords to owner of bounty
            let lords_contract = IERC20CamelDispatcher {
                contract_address: self.lords_address.read(),
            };
            lords_contract
                .transferFrom(get_contract_address(), get_caller_address(), bounty.bounty.into());

            // transfer beast
            let beasts_erc721 = IERC721Dispatcher { contract_address: self.beasts_address.read() };
            beasts_erc721.transfer_from(get_caller_address(), bounty_owner, beast_id);

            // assert bounty inactive
            bounty.active = 0;
            self.bounty.write(bounty_id.into(), bounty);
        }

        fn cancel_bounty(ref self: ContractState, bounty_id: u16) {
            // get bounty
            let mut bounty = self.bounty.read(bounty_id.into());
            let bounty_owner = self.owner.read(bounty_id.into());

            // assert active
            assert(bounty.active == 1, 'bounty not active');

            // assert owner
            assert(bounty_owner == get_caller_address(), 'caller not bounty owner');

            // transfer lords to owner of bounty
            let lords_contract = IERC20CamelDispatcher {
                contract_address: self.lords_address.read(),
            };
            lords_contract.transferFrom(get_contract_address(), bounty_owner, bounty.bounty.into());

            // assert bounty inactive
            bounty.active = 0;
            self.bounty.write(bounty_id.into(), bounty);
        }
    }
}
