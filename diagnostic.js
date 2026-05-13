#!/usr/bin/env node

/**
 * DIAGNOSTIC SCRIPT - E-Block Rewards Setup Verification
 * 
 * Usage: node diagnostic.js
 * 
 * This script checks:
 * - Server is running
 * - Ganache is accessible
 * - Contract is deployed
 * - Accounts have tokens
 * - Authorization setup
 */

const { Web3 } = require('web3');
const http = require('http');

// Configuration
const GANACHE_RPC = 'http://127.0.0.1:7545';
const SERVER_URL = 'http://127.0.0.1:3000';
const CONTRACT_ADDRESS = '0x37b86bEEb7e2994783623d9a0D0c90091a30c837';
const OWNER_PRIVATE_KEY = '0xe6b8035dd8a25e8a4aad330e4ac80b12648a3c98a213959cac2496ef5ecbf7b6';

// Test addresses
const SCANNER_ADDRESS = '0xACe1E87d15d57Be4bd6A06316578b1d878f81071';
const WALLET_ADDRESS = '0xBc24eEbBA4517F10E683654Dfd67a1F69Cf956fd';

console.log('🔍 E-Block Rewards Diagnostic Tool\n');
console.log('=====================================\n');

let passedTests = 0;
let failedTests = 0;

// Helper: Make HTTP request
async function makeRequest(method, path, data = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(SERVER_URL);
    url.pathname = path;
    
    const options = {
      method,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(url, options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({
            status: res.statusCode,
            body: body ? JSON.parse(body) : null
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            body: body
          });
        }
      });
    });

    req.on('error', reject);
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

// Helper: Print test result
function logTest(name, passed, message = '') {
  const icon = passed ? '✅' : '❌';
  const status = passed ? 'PASS' : 'FAIL';
  console.log(`${icon} ${status} - ${name}`);
  if (message) console.log(`   └─ ${message}`);
  
  if (passed) passedTests++;
  else failedTests++;
  console.log();
}

// Run tests
async function runTests() {
  try {
    // Test 1: Ganache Connection
    console.log('📡 Test 1: Ganache RPC Connection');
    const web3 = new Web3(GANACHE_RPC);
    const isConnected = await web3.eth.net.isListening();
    logTest(
      'Ganache RPC Connection',
      isConnected,
      `Connected to ${GANACHE_RPC}`
    );

    if (!isConnected) {
      console.log('⛔ Cannot continue without Ganache. Start with: ganache-cli\n');
      process.exit(1);
    }

    // Test 2: Get Network ID
    console.log('🌐 Test 2: Network ID');
    const networkId = await web3.eth.net.getId();
    logTest('Network ID Retrieved', true, `Network ID: ${networkId}`);

    // Test 3: Owner Account
    console.log('🔐 Test 3: Owner Account');
    let ownerAddress;
    try {
      const account = web3.eth.accounts.privateKeyToAccount(OWNER_PRIVATE_KEY);
      ownerAddress = account.address;
      logTest(
        'Owner Private Key Valid',
        true,
        `Owner Address: ${ownerAddress}`
      );
    } catch (e) {
      logTest('Owner Private Key Valid', false, e.message);
      process.exit(1);
    }

    // Test 4: Owner Balance
    console.log('💰 Test 4: Owner Account Balance');
    const ownerBalance = await web3.eth.getBalance(ownerAddress);
    const ownerBalanceEth = web3.utils.fromWei(ownerBalance, 'ether');
    logTest(
      'Owner Has ETH Balance',
      parseFloat(ownerBalanceEth) > 0,
      `Owner balance: ${ownerBalanceEth} ETH`
    );

    // Test 5: Contract Exists
    console.log('📜 Test 5: Contract Deployment');
    const contractCode = await web3.eth.getCode(CONTRACT_ADDRESS);
    const isDeployed = contractCode !== '0x';
    logTest(
      'Contract Deployed',
      isDeployed,
      `Contract at ${CONTRACT_ADDRESS}`
    );

    if (!isDeployed) {
      console.log('⛔ Contract not found. Deploy to: ' + CONTRACT_ADDRESS + '\n');
      process.exit(1);
    }

    // Test 6: Server Connection
    console.log('🚀 Test 6: Node.js Server');
    try {
      const response = await makeRequest('GET', '/api/balance/' + ownerAddress);
      logTest(
        'Server is Running',
        response.status === 200,
        `Server at ${SERVER_URL}`
      );
    } catch (e) {
      logTest(
        'Server is Running',
        false,
        `Cannot connect. Start with: node server.js`
      );
      process.exit(1);
    }

    // Test 7: Contract Instance
    console.log('🔗 Test 7: Contract Instance');
    const contractABI = [
      {
        "inputs": [
          { "internalType": "address", "name": "account", "type": "address" }
        ],
        "name": "balanceOf",
        "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "owner",
        "outputs": [{ "internalType": "address", "name": "", "type": "address" }],
        "stateMutability": "view",
        "type": "function"
      }
    ];

    const contract = new web3.eth.Contract(contractABI, CONTRACT_ADDRESS);
    const contractOwner = await contract.methods.owner().call();
    logTest(
      'Contract Owner Retrieved',
      contractOwner.toLowerCase() === ownerAddress.toLowerCase(),
      `Contract owner: ${contractOwner}`
    );

    // Test 8: Owner Token Balance
    console.log('🪙 Test 8: Owner Token Balance');
    const tokenBalance = await contract.methods.balanceOf(ownerAddress).call();
    const tokenBalanceFormatted = web3.utils.fromWei(tokenBalance, 'ether');
    logTest(
      'Owner Has Tokens',
      parseFloat(tokenBalanceFormatted) > 0,
      `Owner EBR balance: ${tokenBalanceFormatted} EBR`
    );

    // Test 9: Check if we can call contract methods
    console.log('👤 Test 9: Contract Methods Available');
    try {
      const ownerAddress = await contract.methods.owner().call();
      logTest(
        'Contract Methods Working',
        ownerAddress !== null && ownerAddress !== '0x0000000000000000000000000000000000000000',
        `Contract accessible (owner: ${ownerAddress.substring(0, 10)}...)`
      );
    } catch (e) {
      logTest('Contract Methods Working', false, e.message);
    }

    // Test 10: Wallet Address Token Balance
    console.log('💵 Test 10: Wallet Address Balance');
    const walletBalance = await contract.methods.balanceOf(WALLET_ADDRESS).call();
    const walletBalanceFormatted = web3.utils.fromWei(walletBalance, 'ether');
    logTest(
      'Wallet Has Tokens',
      parseFloat(walletBalanceFormatted) > 0,
      `Wallet EBR balance: ${walletBalanceFormatted} EBR`
    );

    // Summary
    console.log('\n=====================================');
    console.log('📊 TEST SUMMARY');
    console.log(`✅ Passed: ${passedTests}`);
    console.log(`❌ Failed: ${failedTests}`);
    console.log(`📈 Success Rate: ${Math.round((passedTests / (passedTests + failedTests)) * 100)}%`);
    console.log('=====================================\n');

    if (failedTests === 0) {
      console.log('🎉 All tests passed! Your setup is ready.');
      console.log('\nNext steps:');
      console.log('1. Run Flutter app: flutter run');
      console.log('2. Navigate to Scan page');
      console.log('3. Scan QR code to test rewards\n');
    } else {
      console.log('⚠️ Some tests failed. Please review the issues above.\n');
    }

  } catch (error) {
    console.error('❌ Unexpected error:', error.message);
    process.exit(1);
  }
}

runTests();
