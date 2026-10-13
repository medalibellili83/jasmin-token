// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {JasminToken} from "../src/JasminToken.sol";

contract JasminTokenTest is Test {
    JasminToken token;

    // makeAddr crée de fausses adresses pour les tests
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    // 1 million de JSM ("ether" = x 10^18, pour les 18 décimales)
    uint256 constant SUPPLY = 1_000_000 ether;

    // Exécuté avant chaque test : Alice déploie le token
    function setUp() public {
        vm.prank(alice); // la prochaine action est faite "par Alice"
        token = new JasminToken(SUPPLY);
    }

    function test_CreateurRecoitTousLesTokens() public view {
        assertEq(token.totalSupply(), SUPPLY);
        assertEq(token.balanceOf(alice), SUPPLY);
        assertEq(token.balanceOf(bob), 0);
    }

    function test_Transfer() public {
        vm.prank(alice);
        token.transfer(bob, 100 ether);

        assertEq(token.balanceOf(bob), 100 ether);
        assertEq(token.balanceOf(alice), SUPPLY - 100 ether);
    }

    function test_Transfer_EmetEvenement() public {
        vm.expectEmit(true, true, false, true);
        emit JasminToken.Transfer(alice, bob, 1 ether);

        vm.prank(alice);
        token.transfer(bob, 1 ether);
    }

    function test_RevertSi_SoldeInsuffisant() public {
        vm.prank(bob); // Bob n'a aucun token
        vm.expectRevert("Solde insuffisant");
        token.transfer(alice, 1 ether);
    }

    function test_RevertSi_AdresseZero() public {
        vm.prank(alice);
        vm.expectRevert("Adresse invalide");
        token.transfer(address(0), 1 ether);
    }

    function test_ApproveEtTransferFrom() public {
        vm.prank(alice);
        token.approve(bob, 50 ether);

        vm.prank(bob);
        token.transferFrom(alice, bob, 30 ether);

        assertEq(token.balanceOf(bob), 30 ether);
        assertEq(token.allowance(alice, bob), 20 ether);
    }

    function test_RevertSi_AutorisationInsuffisante() public {
        vm.prank(bob); // Alice n'a rien autorisé
        vm.expectRevert("Autorisation insuffisante");
        token.transferFrom(alice, bob, 1 ether);
    }

    function test_Burn() public {
        vm.prank(alice);
        token.burn(400 ether);

        assertEq(token.balanceOf(alice), SUPPLY - 400 ether);
        assertEq(token.totalSupply(), SUPPLY - 400 ether);
    }

    function test_Burn_EmetEvenement() public {
        vm.expectEmit(true, true, false, true);
        emit JasminToken.Transfer(alice, address(0), 1 ether);

        vm.prank(alice);
        token.burn(1 ether);
    }

    function test_RevertSi_BurnPlusQueSonSolde() public {
        vm.prank(bob); // Bob n'a aucun token
        vm.expectRevert("Solde insuffisant");
        token.burn(1 ether);
    }

    // Test "fuzz" : Foundry essaie automatiquement des centaines de montants aléatoires.
    // C'est l'outil n°1 des auditeurs pour trouver des failles.
    function testFuzz_TransferConserveLeTotal(uint256 montant) public {
        montant = bound(montant, 0, SUPPLY);

        vm.prank(alice);
        token.transfer(bob, montant);

        assertEq(token.balanceOf(alice) + token.balanceOf(bob), SUPPLY);
    }
}
