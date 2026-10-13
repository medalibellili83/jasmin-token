// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Jasmin Token (JSM)
/// @notice Un token ERC-20 écrit à la main, sans bibliothèque, pour comprendre
///         comment fonctionnent les tokens comme l'USDT ou l'USDC.
contract JasminToken {
    // --- Informations du token ---
    string public constant name = "Jasmin Token";
    string public constant symbol = "JSM";
    // 18 décimales : 1 JSM = 1_000_000_000_000_000_000 unités (comme ETH et wei)
    uint8 public constant decimals = 18;

    uint256 public totalSupply;

    // Le "registre" du token : adresse => solde
    mapping(address => uint256) public balanceOf;

    // Les autorisations : propriétaire => (dépenseur => montant autorisé)
    mapping(address => mapping(address => uint256)) public allowance;

    // Les événements permettent aux wallets et aux sites (Etherscan...) de suivre les mouvements
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @param initialSupply nombre total de tokens créés, donnés à celui qui déploie le contrat
    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    /// @notice Envoyer des tokens à quelqu'un
    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    /// @notice Autoriser `spender` (souvent une application, ex : un exchange) à dépenser vos tokens
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// @notice Dépenser les tokens de `from`, si `from` vous a autorisé avec `approve`
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= amount, "Autorisation insuffisante");
        // Convention : une autorisation "infinie" n'est jamais diminuée
        if (allowed != type(uint256).max) {
            allowance[from][msg.sender] = allowed - amount;
        }
        _transfer(from, to, amount);
        return true;
    }

    /// @notice Détruire ses propres tokens : ils disparaissent pour toujours et le totalSupply baisse
    function burn(uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "Solde insuffisant");
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "Adresse invalide");
        require(balanceOf[from] >= amount, "Solde insuffisant");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }
}
