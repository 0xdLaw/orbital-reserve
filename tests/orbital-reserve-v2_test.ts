import { Clarinet, Tx, Chain, Account, Types } from 'https://deno.land/x/clarinet@v1.5.4/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

// 🛑 Test 1: Circuit Breaker Integrity
Clarinet.test({
    name: "CIRCUIT BREAKER: Should block execution when open, reject unauthorized users, and allow governance reset",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet_1 = accounts.get('wallet_1')!; // Attacker account

        // 1. Try to flip breaker as a random user (Should Fail)
        let block1 = chain.mineBlock([
            Tx.contractCall('orbital-reserve-v2', 'emergency-circuit-breaker', [], wallet_1.address)
        ]);
        // Asserts that it returned (err u1001) ERR_UNAUTHORIZED
        block1.receipts[0].result.expectErr().expectUint(1001);

        // 2. Flip breaker as authorized Governance (Should Pass)
        let block2 = chain.mineBlock([
            Tx.contractCall('orbital-reserve-v2', 'emergency-circuit-breaker', [], deployer.address)
        ]);
        block2.receipts[0].result.expectOk().expectBool(true);

        // 3. Try to harvest while breaker is open (Should Fail)
        let block3 = chain.mineBlock([
            Tx.contractCall('orbital-reserve-v2', 'harvest-yields', [Types.uint(100)], deployer.address)
        ]);
        // Asserts system blocks it due to circuit breaker being open
        block3.receipts[0].result.expectErr().expectUint(1001); // Adjust if your ERR_CIRCUIT_BREAKER_OPEN has a unique code

        // 4. Reset breaker using our new function (Should Pass)
        let block4 = chain.mineBlock([
            Tx.contractCall('orbital-reserve-v2', 'reset-circuit-breaker', [], deployer.address)
        ]);
        block4.receipts[0].result.expectOk().expectBool(true);
    },
});

// 🧈 Test 2: The Stage 1 -> Stage 2 Malicious Slippage Gauntlet
Clarinet.test({
    name: "SLIPPAGE GUARDRAIL: Should successfully process stage 1 harvest and cleanly reject malicious slippage at stage 2",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;

        // 1. Execute Stage 1: Harvest yields (Gas fee set to normal u100)
        let stage1Block = chain.mineBlock([
            Tx.contractCall('orbital-reserve-v2', 'harvest-yields', [Types.uint(100)], deployer.address)
        ]);
        stage1Block.receipts[0].result.expectOk().expectBool(true);

        // 2. Execute Stage 2: Try to compound but demand an impossible 50,000,000 sats
        let stage2Block = chain.mineBlock([
            Tx.contractCall('orbital-reserve-v2', 'compound-buffer', [Types.uint(50000000)], deployer.address)
        ]);

        // 🎯 The exact verification point we hit manually! 
        // Expects the transaction to abort and roll back with your verified (err u1004)
        stage2Block.receipts[0].result.expectErr().expectUint(1004);
    },
});
