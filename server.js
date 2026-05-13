const express = require('express');
const { Web3 } = require('web3');
const cors = require('cors');


const app = express();
app.use(express.json({ limit: '10mb' })); // Increase limit to handle larger payloads
app.use(express.urlencoded({ limit: '10mb', extended: true }));
app.use(cors());

// Debug middleware - log all requests
app.use((req, res, next) => {
  console.log(`\n📍 ${req.method} ${req.path}`);
  console.log('Headers:', req.headers);
  console.log('Body:', req.body);
  next();
});

// CONNECT TO GANACHE
const web3 = new Web3('http://127.0.0.1:7545'); 

// 1. PASTE YOUR CONTRACT ADDRESS HERE
const contractAddress = '0x37b86bEEb7e2994783623d9a0D0c90091a30c837';


const contractABI = [
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "Approval",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "previousOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnershipTransferred",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "binID",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "itemType",
				"type": "string"
			}
		],
		"name": "RewardIssued",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "Transfer",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			}
		],
		"name": "allowance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "approve",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "balanceOf",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_user",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "_binID",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "_rewardAmount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_weight",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "_itemType",
				"type": "string"
			}
		],
		"name": "claimReward",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "decimals",
		"outputs": [
			{
				"internalType": "uint8",
				"name": "",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "subtractedValue",
				"type": "uint256"
			}
		],
		"name": "decreaseAllowance",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "addedValue",
				"type": "uint256"
			}
		],
		"name": "increaseAllowance",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_binID",
				"type": "string"
			}
		],
		"name": "isBinAvailable",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "name",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "renounceOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "symbol",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "totalSupply",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "transfer",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "transferFrom",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "transferOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"name": "usedBins",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "userTotalWaste",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
];

const contract = new web3.eth.Contract(contractABI, contractAddress);

const ownerPrivateKey = '0x0b6de915ba7a0d2bce86f0366e43df9b1a53fcbf22630dcf432462e445fefdac'; 


const EWASTE_CATEGORIES = [
    {
        category: 'Mobile Devices',
        subType: 'Smartphone, Phablet',
        minWeight: 0.15,
        maxWeight: 0.25,
        rewardPerKg: 10.0,
    },
    {
        category: 'Power Storage',
        subType: 'Lithium-Ion Battery, Power Bank',
        minWeight: 0.30,
        maxWeight: 0.80,
        rewardPerKg: 15.0,
    },
    {
        category: 'Computing Hardware',
        subType: 'Laptop, Tablet, Notebook',
        minWeight: 1.20,
        maxWeight: 2.50,
        rewardPerKg: 25.0,
    },
    {
        category: 'Peripherals',
        subType: 'Mouse, Keyboard, Cables',
        minWeight: 0.05,
        maxWeight: 0.50,
        rewardPerKg: 5.0,
    },
    {
        category: 'Component Level',
        subType: 'Motherboard, RAM Stick, GPU',
        minWeight: 0.10,
        maxWeight: 0.60,
        rewardPerKg: 20.0,
    },
];

// Function to select random e-waste and calculate reward
function selectRandomEwaste() {
    const index = Math.floor(Math.random() * EWASTE_CATEGORIES.length);
    const selected = EWASTE_CATEGORIES[index];

    // Generate random weight within range
    const randomWeight = selected.minWeight + (Math.random() * (selected.maxWeight - selected.minWeight));
    
    // Calculate reward
    const rewardAmount = Math.round(randomWeight * selected.rewardPerKg * 100) / 100;

    const result = {
        category: selected.category,
        subType: selected.subType,
        weight: parseFloat(randomWeight.toFixed(2)),
        rewardPerKg: selected.rewardPerKg,
        rewardAmount: Math.floor(rewardAmount)
    };
    
    // Debug logging
    console.log(`📊 [E-WASTE] Random selection: index=${index}/${EWASTE_CATEGORIES.length-1}, category=${result.category}`);
    
    return result;
} 



app.post('/api/reward', async (req, res) => {
    // Validate request body exists
    if (!req.body || typeof req.body !== 'object') {
        console.error('⚠️ Empty or invalid request body:', req.body);
        return res.status(400).json({ error: 'Invalid request body - ensure Content-Type is application/json' });
    }

    const { user } = req.body;
    
    // Validate required fields
    if (!user) {
        console.error('⚠️ Missing required fields. Body:', req.body);
        return res.status(400).json({ error: 'Missing required fields: user' });
    }

    console.log(`♻️  [REWARD] Processing reward request`);
    console.log(`   User Address: ${user}`);

    try {
        // Select random e-waste item and calculate reward
        const ewasteData = selectRandomEwaste();
        const weight = ewasteData.weight;
        const rewardAmount = ewasteData.rewardAmount;

        console.log(`📦 [REWARD] Selected: ${ewasteData.category} (${ewasteData.subType})`);
        console.log(`   Weight: ${weight}kg, Reward: ${rewardAmount} EBR`);

        const ownerAccount = web3.eth.accounts.privateKeyToAccount(ownerPrivateKey);
        console.log(`🔐 [REWARD] Owner account: ${ownerAccount.address}`);

		// Guard against self-transfer: owner -> owner does not change visible balance.
		if (user.toLowerCase() === ownerAccount.address.toLowerCase()) {
			return res.status(400).json({
				error: 'Reward target cannot be the owner account. Use a different user wallet address to see balance updates.'
			});
		}

        // Convert reward amount to wei (tokens have 18 decimals)
        const rewardInWei = web3.utils.toWei(rewardAmount.toString(), 'ether');

        // Use ERC20 transfer() to actually give tokens to the user
        const tx = contract.methods.transfer(user, rewardInWei);

        // Estimate Gas
        console.log(`⛽ [REWARD] Estimating gas...`);
        const gas = await tx.estimateGas({ from: ownerAccount.address });
        console.log(`⛽ [REWARD] Estimated gas: ${gas}`);

        // Sign Transaction
        const signedTx = await web3.eth.accounts.signTransaction(
            {
                from: ownerAccount.address,
                to: contractAddress,
                data: tx.encodeABI(),
                gas: gas,
                gasPrice: await web3.eth.getGasPrice()
            },
            ownerPrivateKey
        );
        console.log(`✍️  [REWARD] Transaction signed`);

        // Send Transaction
        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);

        console.log(`✅ [REWARD] Reward Sent! TX: ${receipt.transactionHash}`);

        // Return reward with e-waste data
        res.json({
            success: true,
            tx: receipt.transactionHash,
            tokens: rewardAmount,
            ewasteData: ewasteData
        });

    } catch (error) {
        console.error(`❌ [REWARD] Error: ${error.message}`);

        // Provide specific error messages
        if (error.message.includes('gas')) {
            console.error(`   → Gas estimation failed. Check sufficient balance.`);
        }

        res.status(500).json({ error: error.message });
    }
});

// GET USER BALANCE FROM BLOCKCHAIN
app.get('/api/balance/:address', async (req, res) => {
    try {
        const userAddress = req.params.address;
        
        // Connect to your deployed contract
        const contract = new web3.eth.Contract(contractABI, contractAddress);
        
        // Call the built-in ERC20 balanceOf function
        const balanceWei = await contract.methods.balanceOf(userAddress).call();
        
        // Convert from 18 decimal format to standard format
        const balanceEBR = web3.utils.fromWei(balanceWei, 'ether');
        
        // Log for debugging
        console.log(`📊 [BALANCE] Query for ${userAddress.substring(0, 10)}...`);
        console.log(`   └─ Balance: ${balanceEBR} EBR (${balanceWei} wei)`);
        
        // Send the number back to the Flutter app!
        res.json({ balance: balanceEBR });
        
    } catch (error) {
        console.error("Error fetching balance:", error);
        res.status(500).json({ error: error.message });
    }
});


app.post('/api/withdraw', async (req, res) => {
    try {
        // ===== INPUT VALIDATION =====
        if (!req.body || typeof req.body !== 'object') {
            console.error('⚠️ Empty or invalid request body');
            return res.status(400).json({ 
                success: false,
                error: 'Invalid request body - ensure Content-Type is application/json' 
            });
        }

        const { userAddress, amount } = req.body;

        // Validate required fields
        if (!userAddress || !amount) {
            console.error('⚠️ Missing required fields. Body:', req.body);
            return res.status(400).json({ 
                success: false,
                error: 'Missing required fields: userAddress, amount' 
            });
        }

        
        if (!web3.utils.isAddress(userAddress)) {
            return res.status(400).json({ 
                success: false,
                error: 'Invalid Ethereum address format' 
            });
        }

        // Convert amount from EBR to Wei (18 decimals)
        let withdrawalAmountWei;
        try {
            withdrawalAmountWei = web3.utils.toWei(amount.toString(), 'ether');
        } catch (e) {
            return res.status(400).json({ 
                success: false,
                error: 'Invalid amount format' 
            });
        }

        console.log(`💰 Withdrawal Request - User: ${userAddress}, Amount: ${amount} EBR`);

        // ===== VALIDATION CHECKS ON BLOCKCHAIN =====
        // Check user's balance
        const userBalance = await contract.methods.balanceOf(userAddress).call();
        if (BigInt(userBalance) < BigInt(withdrawalAmountWei)) {
            console.error(`❌ Insufficient Funds - User balance: ${web3.utils.fromWei(userBalance, 'ether')} EBR, Requested: ${amount} EBR`);
            return res.status(400).json({ 
                success: false,
                error: 'Insufficient Funds',
                details: {
                    userBalance: web3.utils.fromWei(userBalance, 'ether'),
                    requestedAmount: amount
                }
            });
        }

		// Check owner's balance because owner is the sender in executeWithdrawalTransaction().
		const ownerAccount = web3.eth.accounts.privateKeyToAccount(ownerPrivateKey);
		const ownerBalance = await contract.methods.balanceOf(ownerAccount.address).call();
		if (BigInt(ownerBalance) < BigInt(withdrawalAmountWei)) {
			console.error(`❌ Owner Insufficient Funds - Owner balance: ${web3.utils.fromWei(ownerBalance, 'ether')} EBR, Requested: ${amount} EBR`);
			return res.status(503).json({ 
				success: false,
				error: 'Service Unavailable - Owner has insufficient token balance',
				details: {
					ownerAddress: ownerAccount.address,
					ownerBalance: web3.utils.fromWei(ownerBalance, 'ether'),
					requestedAmount: amount
				}
			});
		}

        // ===== FACADE LAYER: TRANSACTION SIGNING & EXECUTION =====
        // This facade abstracts the complex Web3 operations
        const transaction = await executeWithdrawalTransaction(
            userAddress,
            withdrawalAmountWei,
            amount
        );

        console.log(`✅ Withdrawal Successful! TX: ${transaction.transactionHash}`);
        res.json({ 
            success: true, 
            transactionHash: transaction.transactionHash,
            amount: amount,
            message: 'Withdrawal successful',
            blockNumber: transaction.blockNumber
        });

    } catch (error) {
        console.error('❌ Withdrawal Error:', error.message);
        
        // Handle specific error types
        if (error.message.includes('Insufficient Funds')) {
            return res.status(400).json({ 
                success: false,
                error: 'Insufficient Funds',
                details: error.message
            });
        }

        if (error.message.includes('gas')) {
            return res.status(500).json({ 
                success: false,
                error: 'Gas estimation failed',
                details: 'Transaction would fail - possibly insufficient gas or contract error'
            });
        }

        res.status(500).json({ 
            success: false,
            error: 'Withdrawal failed',
            details: error.message
        });
    }
});


async function executeWithdrawalTransaction(userAddress, amountWei, amountDisplay) {
    try {
        // Get owner account from private key
        const ownerAccount = web3.eth.accounts.privateKeyToAccount(ownerPrivateKey);
        console.log(`🔐 Signing transaction from: ${ownerAccount.address}`);

        // Convert amountWei to string to avoid BigInt mixing errors
        const amountWeiString = amountWei.toString();

        // Step 1: Use transfer() instead of withdraw() - owner transfers tokens directly to user
        // This avoids contract revert issues with msg.sender checks
        const transferTx = contract.methods.transfer(userAddress, amountWeiString);

        // Step 2: Estimate Gas
        const estimatedGas = await transferTx.estimateGas({ 
            from: ownerAccount.address 
        });
        const gasLimit = Math.floor(Number(estimatedGas) * 1.1); // Add 10% buffer, convert BigInt to Number
        console.log(`⛽ Estimated Gas: ${estimatedGas}, Using: ${gasLimit}`);

        // Step 3: Get current gas price from Ganache
        const gasPrice = await web3.eth.getGasPrice();
        console.log(`💵 Gas Price: ${gasPrice} wei`);

        // Step 4: Create raw transaction object
        const txData = {
            from: ownerAccount.address,
            to: contractAddress,
            data: transferTx.encodeABI(),
            gas: gasLimit.toString(),
            gasPrice: gasPrice.toString(),
            nonce: (await web3.eth.getTransactionCount(ownerAccount.address)).toString()
        };

        console.log(`📝 Transaction Data prepared:`, {
            from: txData.from,
            to: txData.to,
            gas: txData.gas,
            gasPrice: txData.gasPrice,
            nonce: txData.nonce
        });

        // Step 5: Sign transaction with owner's private key
        const signedTx = await web3.eth.accounts.signTransaction(txData, ownerPrivateKey);
        console.log(`✍️ Transaction signed. Signature: ${signedTx.signature}`);

        // Step 6: Send signed transaction to Ganache
        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
        console.log(`🔗 Transaction mined! Block Number: ${receipt.blockNumber}`);

        return {
            transactionHash: receipt.transactionHash,
            blockNumber: receipt.blockNumber.toString(),
            gasUsed: receipt.gasUsed.toString(),
            status: Number(receipt.status)
        };

    } catch (error) {
        console.error('❌ Transaction Execution Error:', error);
        throw error;
    }
}

// Initialize: Check contract deployment and owner
async function initializeServer() {
    console.log('\n🔧 [INIT] Initializing server...');
    try {
        const ownerAccount = web3.eth.accounts.privateKeyToAccount(ownerPrivateKey);
        console.log(`🔐 [INIT] Owner account: ${ownerAccount.address}`);

        // Check if contract is deployed
        const codeAtAddress = await web3.eth.getCode(contractAddress);
        if (codeAtAddress === '0x') {
            console.error(`❌ [INIT] No contract found at ${contractAddress}`);
            return;
        }
        console.log(`✅ [INIT] Contract deployed at ${contractAddress}`);

        // Check contract owner
        const contractOwner = await contract.methods.owner().call();
        console.log(`👤 [INIT] Contract owner: ${contractOwner}`);

        // Check owner balance
        const ownerBalance = await contract.methods.balanceOf(ownerAccount.address).call();
        const ownerBalanceEther = web3.utils.fromWei(ownerBalance, 'ether');
        console.log(`💰 [INIT] Owner token balance: ${ownerBalanceEther} EBR`);

        console.log(`✅ [INIT] Server initialization complete!`);

    } catch (error) {
        console.error(`❌ [INIT] Error during initialization: ${error.message}`);
    }
    console.log('');
}

// Start server
app.listen(3000, async () => {
    console.log('🚀 API running on http://localhost:3000');
    await initializeServer();
});