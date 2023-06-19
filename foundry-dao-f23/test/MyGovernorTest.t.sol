// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {Box} from "../src/Box.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {GovToken} from "../src/GovToken.sol";

contract MyGovernorTest is Test {
    MyGovernor governor;
    Box box;
    TimeLock timelock;
    GovToken govToken;

    address public USER = makeAddr("user");
    uint256 public constant INITIAL_SUPPLY = 100 ether;

    address[] proposers;
    address[] executors;

    uint256[] values;
    bytes[] calldatas;
    address[] targets;

    uint256 public constant MIN_DELAY = 3600; // 1 hour - minimum time to wait before executing a proposal
    uint256 public constant VOTING_DELAY = 1; // how many blocks till a vote is active
    uint256 public constant VOTING_PERIOD = 50400;

    function setUp() public {
        govToken = new GovToken();
        govToken.mint(USER, INITIAL_SUPPLY);

        vm.startPrank(USER);
        govToken.delegate(USER);
        timelock = new TimeLock(MIN_DELAY, proposers, executors); // blank arrays means anyone can propose and execute
        governor = new MyGovernor(govToken, timelock);

        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.TIMELOCK_ADMIN_ROLE();

        timelock.grantRole(proposerRole, address(governor)); // only governor can propose to timelock
        timelock.grantRole(executorRole, address(0)); // anybody can execute passed proposals
        timelock.revokeRole(adminRole, USER); // remove admin role from user
        vm.stopPrank();

        box = new Box();
        box.transferOwnership(address(timelock));
    }

    function testCantUpdateBoxWithoutGovernance() public {
        vm.expectRevert();
        box.store(1);
    }

    function testGovernanceUpdatesBox() public {
        uint256 valueToStore = 888;
        string memory description = "store 888 in Box";
        bytes memory encodedFunctionCall = abi.encodeWithSignature("store(uint256)", valueToStore);

        values.push(0); // no ETH to send
        calldatas.push(encodedFunctionCall);
        targets.push(address(box));

        // 1. Propose to the DAO
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // View the state of the proposal
        console.log("Proposal State: ", uint256(governor.state(proposalId))); // should return 0 (PENDING)

        vm.warp(block.timestamp + VOTING_DELAY + 1); // fast forward 1 block
        vm.roll(block.number + VOTING_DELAY + 1); // increase block number

        console.log("Proposal State: ", uint256(governor.state(proposalId))); // should return 1 (ACTIVE)

        // 2. Vote on the proposal
        string memory reason = "cuz blue frog is cool";
        uint8 voteWay = 1; // 1 = for, 2 = against, 3 = abstain
        vm.prank(USER);
        governor.castVoteWithReason(proposalId, voteWay, reason);

        // speed through voting period
        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        // 3. Queue the TX of proposal
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governor.queue(targets, values, calldatas, descriptionHash);

        // 4. Execute the TX of proposal
    }
}
