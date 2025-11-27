// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package networkcontracts

import (
	"errors"
	"math/big"
	"strings"

	ethereum "github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/event"
)

// Reference imports to suppress errors if they are not otherwise used.
var (
	_ = errors.New
	_ = big.NewInt
	_ = strings.NewReader
	_ = ethereum.NotFound
	_ = bind.Bind
	_ = common.Big1
	_ = types.BloomLookup
	_ = event.NewSubscription
	_ = abi.ConvertType
)

// ISetMaxNetworkLimitHookMetaData contains all meta data concerning the ISetMaxNetworkLimitHook contract.
var ISetMaxNetworkLimitHookMetaData = &bind.MetaData{
	ABI: "[{\"type\":\"function\",\"name\":\"setMaxNetworkLimit\",\"inputs\":[{\"name\":\"delegator\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"subnetworkId\",\"type\":\"uint96\",\"internalType\":\"uint96\"},{\"name\":\"maxNetworkLimit\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"}]",
}

// ISetMaxNetworkLimitHookABI is the input ABI used to generate the binding from.
// Deprecated: Use ISetMaxNetworkLimitHookMetaData.ABI instead.
var ISetMaxNetworkLimitHookABI = ISetMaxNetworkLimitHookMetaData.ABI

// ISetMaxNetworkLimitHook is an auto generated Go binding around an Ethereum contract.
type ISetMaxNetworkLimitHook struct {
	ISetMaxNetworkLimitHookCaller     // Read-only binding to the contract
	ISetMaxNetworkLimitHookTransactor // Write-only binding to the contract
	ISetMaxNetworkLimitHookFilterer   // Log filterer for contract events
}

// ISetMaxNetworkLimitHookCaller is an auto generated read-only Go binding around an Ethereum contract.
type ISetMaxNetworkLimitHookCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// ISetMaxNetworkLimitHookTransactor is an auto generated write-only Go binding around an Ethereum contract.
type ISetMaxNetworkLimitHookTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// ISetMaxNetworkLimitHookFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type ISetMaxNetworkLimitHookFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// ISetMaxNetworkLimitHookSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type ISetMaxNetworkLimitHookSession struct {
	Contract     *ISetMaxNetworkLimitHook // Generic contract binding to set the session for
	CallOpts     bind.CallOpts            // Call options to use throughout this session
	TransactOpts bind.TransactOpts        // Transaction auth options to use throughout this session
}

// ISetMaxNetworkLimitHookCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type ISetMaxNetworkLimitHookCallerSession struct {
	Contract *ISetMaxNetworkLimitHookCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts                  // Call options to use throughout this session
}

// ISetMaxNetworkLimitHookTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type ISetMaxNetworkLimitHookTransactorSession struct {
	Contract     *ISetMaxNetworkLimitHookTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts                  // Transaction auth options to use throughout this session
}

// ISetMaxNetworkLimitHookRaw is an auto generated low-level Go binding around an Ethereum contract.
type ISetMaxNetworkLimitHookRaw struct {
	Contract *ISetMaxNetworkLimitHook // Generic contract binding to access the raw methods on
}

// ISetMaxNetworkLimitHookCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type ISetMaxNetworkLimitHookCallerRaw struct {
	Contract *ISetMaxNetworkLimitHookCaller // Generic read-only contract binding to access the raw methods on
}

// ISetMaxNetworkLimitHookTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type ISetMaxNetworkLimitHookTransactorRaw struct {
	Contract *ISetMaxNetworkLimitHookTransactor // Generic write-only contract binding to access the raw methods on
}

// NewISetMaxNetworkLimitHook creates a new instance of ISetMaxNetworkLimitHook, bound to a specific deployed contract.
func NewISetMaxNetworkLimitHook(address common.Address, backend bind.ContractBackend) (*ISetMaxNetworkLimitHook, error) {
	contract, err := bindISetMaxNetworkLimitHook(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &ISetMaxNetworkLimitHook{ISetMaxNetworkLimitHookCaller: ISetMaxNetworkLimitHookCaller{contract: contract}, ISetMaxNetworkLimitHookTransactor: ISetMaxNetworkLimitHookTransactor{contract: contract}, ISetMaxNetworkLimitHookFilterer: ISetMaxNetworkLimitHookFilterer{contract: contract}}, nil
}

// NewISetMaxNetworkLimitHookCaller creates a new read-only instance of ISetMaxNetworkLimitHook, bound to a specific deployed contract.
func NewISetMaxNetworkLimitHookCaller(address common.Address, caller bind.ContractCaller) (*ISetMaxNetworkLimitHookCaller, error) {
	contract, err := bindISetMaxNetworkLimitHook(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &ISetMaxNetworkLimitHookCaller{contract: contract}, nil
}

// NewISetMaxNetworkLimitHookTransactor creates a new write-only instance of ISetMaxNetworkLimitHook, bound to a specific deployed contract.
func NewISetMaxNetworkLimitHookTransactor(address common.Address, transactor bind.ContractTransactor) (*ISetMaxNetworkLimitHookTransactor, error) {
	contract, err := bindISetMaxNetworkLimitHook(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &ISetMaxNetworkLimitHookTransactor{contract: contract}, nil
}

// NewISetMaxNetworkLimitHookFilterer creates a new log filterer instance of ISetMaxNetworkLimitHook, bound to a specific deployed contract.
func NewISetMaxNetworkLimitHookFilterer(address common.Address, filterer bind.ContractFilterer) (*ISetMaxNetworkLimitHookFilterer, error) {
	contract, err := bindISetMaxNetworkLimitHook(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &ISetMaxNetworkLimitHookFilterer{contract: contract}, nil
}

// bindISetMaxNetworkLimitHook binds a generic wrapper to an already deployed contract.
func bindISetMaxNetworkLimitHook(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := ISetMaxNetworkLimitHookMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_ISetMaxNetworkLimitHook *ISetMaxNetworkLimitHookRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _ISetMaxNetworkLimitHook.Contract.ISetMaxNetworkLimitHookCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_ISetMaxNetworkLimitHook *ISetMaxNetworkLimitHookRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _ISetMaxNetworkLimitHook.Contract.ISetMaxNetworkLimitHookTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_ISetMaxNetworkLimitHook *ISetMaxNetworkLimitHookRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _ISetMaxNetworkLimitHook.Contract.ISetMaxNetworkLimitHookTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_ISetMaxNetworkLimitHook *ISetMaxNetworkLimitHookCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _ISetMaxNetworkLimitHook.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_ISetMaxNetworkLimitHook *ISetMaxNetworkLimitHookTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _ISetMaxNetworkLimitHook.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_ISetMaxNetworkLimitHook *ISetMaxNetworkLimitHookTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _ISetMaxNetworkLimitHook.Contract.contract.Transact(opts, method, params...)
}

// SetMaxNetworkLimit is a paid mutator transaction binding the contract method 0x6773522c.
//
// Solidity: function setMaxNetworkLimit(address delegator, uint96 subnetworkId, uint256 maxNetworkLimit) returns()
func (_ISetMaxNetworkLimitHook *ISetMaxNetworkLimitHookTransactor) SetMaxNetworkLimit(opts *bind.TransactOpts, delegator common.Address, subnetworkId *big.Int, maxNetworkLimit *big.Int) (*types.Transaction, error) {
	return _ISetMaxNetworkLimitHook.contract.Transact(opts, "setMaxNetworkLimit", delegator, subnetworkId, maxNetworkLimit)
}

// SetMaxNetworkLimit is a paid mutator transaction binding the contract method 0x6773522c.
//
// Solidity: function setMaxNetworkLimit(address delegator, uint96 subnetworkId, uint256 maxNetworkLimit) returns()
func (_ISetMaxNetworkLimitHook *ISetMaxNetworkLimitHookSession) SetMaxNetworkLimit(delegator common.Address, subnetworkId *big.Int, maxNetworkLimit *big.Int) (*types.Transaction, error) {
	return _ISetMaxNetworkLimitHook.Contract.SetMaxNetworkLimit(&_ISetMaxNetworkLimitHook.TransactOpts, delegator, subnetworkId, maxNetworkLimit)
}

// SetMaxNetworkLimit is a paid mutator transaction binding the contract method 0x6773522c.
//
// Solidity: function setMaxNetworkLimit(address delegator, uint96 subnetworkId, uint256 maxNetworkLimit) returns()
func (_ISetMaxNetworkLimitHook *ISetMaxNetworkLimitHookTransactorSession) SetMaxNetworkLimit(delegator common.Address, subnetworkId *big.Int, maxNetworkLimit *big.Int) (*types.Transaction, error) {
	return _ISetMaxNetworkLimitHook.Contract.SetMaxNetworkLimit(&_ISetMaxNetworkLimitHook.TransactOpts, delegator, subnetworkId, maxNetworkLimit)
}
