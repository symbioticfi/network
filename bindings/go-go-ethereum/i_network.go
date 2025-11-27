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

// INetworkDelayParams is an auto generated low-level Go binding around an user-defined struct.
type INetworkDelayParams struct {
	Target   common.Address
	Selector [4]byte
	Delay    *big.Int
}

// INetworkNetworkInitParams is an auto generated low-level Go binding around an user-defined struct.
type INetworkNetworkInitParams struct {
	GlobalMinDelay              *big.Int
	DelayParams                 []INetworkDelayParams
	Proposers                   []common.Address
	Executors                   []common.Address
	Name                        string
	MetadataURI                 string
	DefaultAdminRoleHolder      common.Address
	NameUpdateRoleHolder        common.Address
	MetadataURIUpdateRoleHolder common.Address
}

// INetworkMetaData contains all meta data concerning the INetwork contract.
var INetworkMetaData = &bind.MetaData{
	ABI: "[{\"type\":\"function\",\"name\":\"METADATA_URI_UPDATE_ROLE\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"NAME_UPDATE_ROLE\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"NETWORK_MIDDLEWARE_SERVICE\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"NETWORK_REGISTRY\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"getMinDelay\",\"inputs\":[{\"name\":\"target\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"data\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"initialize\",\"inputs\":[{\"name\":\"networkInitParams\",\"type\":\"tuple\",\"internalType\":\"structINetwork.NetworkInitParams\",\"components\":[{\"name\":\"globalMinDelay\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"delayParams\",\"type\":\"tuple[]\",\"internalType\":\"structINetwork.DelayParams[]\",\"components\":[{\"name\":\"target\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"selector\",\"type\":\"bytes4\",\"internalType\":\"bytes4\"},{\"name\":\"delay\",\"type\":\"uint256\",\"internalType\":\"uint256\"}]},{\"name\":\"proposers\",\"type\":\"address[]\",\"internalType\":\"address[]\"},{\"name\":\"executors\",\"type\":\"address[]\",\"internalType\":\"address[]\"},{\"name\":\"name\",\"type\":\"string\",\"internalType\":\"string\"},{\"name\":\"metadataURI\",\"type\":\"string\",\"internalType\":\"string\"},{\"name\":\"defaultAdminRoleHolder\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"nameUpdateRoleHolder\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"metadataURIUpdateRoleHolder\",\"type\":\"address\",\"internalType\":\"address\"}]}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"metadataURI\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"string\",\"internalType\":\"string\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"name\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"string\",\"internalType\":\"string\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"setMaxNetworkLimit\",\"inputs\":[{\"name\":\"delegator\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"subnetworkId\",\"type\":\"uint96\",\"internalType\":\"uint96\"},{\"name\":\"maxNetworkLimit\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"updateDelay\",\"inputs\":[{\"name\":\"target\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"selector\",\"type\":\"bytes4\",\"internalType\":\"bytes4\"},{\"name\":\"enabled\",\"type\":\"bool\",\"internalType\":\"bool\"},{\"name\":\"newDelay\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"updateMetadataURI\",\"inputs\":[{\"name\":\"metadataURI\",\"type\":\"string\",\"internalType\":\"string\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"updateName\",\"inputs\":[{\"name\":\"name\",\"type\":\"string\",\"internalType\":\"string\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"event\",\"name\":\"MetadataURISet\",\"inputs\":[{\"name\":\"metadataURI\",\"type\":\"string\",\"indexed\":false,\"internalType\":\"string\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"MinDelayChange\",\"inputs\":[{\"name\":\"target\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"selector\",\"type\":\"bytes4\",\"indexed\":true,\"internalType\":\"bytes4\"},{\"name\":\"oldEnabledStatus\",\"type\":\"bool\",\"indexed\":false,\"internalType\":\"bool\"},{\"name\":\"oldDelay\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"newEnabledStatus\",\"type\":\"bool\",\"indexed\":false,\"internalType\":\"bool\"},{\"name\":\"newDelay\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"NameSet\",\"inputs\":[{\"name\":\"name\",\"type\":\"string\",\"indexed\":false,\"internalType\":\"string\"}],\"anonymous\":false},{\"type\":\"error\",\"name\":\"InvalidDataLength\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InvalidNewDelay\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InvalidTargetAndSelector\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"NotMiddleware\",\"inputs\":[]}]",
}

// INetworkABI is the input ABI used to generate the binding from.
// Deprecated: Use INetworkMetaData.ABI instead.
var INetworkABI = INetworkMetaData.ABI

// INetwork is an auto generated Go binding around an Ethereum contract.
type INetwork struct {
	INetworkCaller     // Read-only binding to the contract
	INetworkTransactor // Write-only binding to the contract
	INetworkFilterer   // Log filterer for contract events
}

// INetworkCaller is an auto generated read-only Go binding around an Ethereum contract.
type INetworkCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// INetworkTransactor is an auto generated write-only Go binding around an Ethereum contract.
type INetworkTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// INetworkFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type INetworkFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// INetworkSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type INetworkSession struct {
	Contract     *INetwork         // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// INetworkCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type INetworkCallerSession struct {
	Contract *INetworkCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts   // Call options to use throughout this session
}

// INetworkTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type INetworkTransactorSession struct {
	Contract     *INetworkTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts   // Transaction auth options to use throughout this session
}

// INetworkRaw is an auto generated low-level Go binding around an Ethereum contract.
type INetworkRaw struct {
	Contract *INetwork // Generic contract binding to access the raw methods on
}

// INetworkCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type INetworkCallerRaw struct {
	Contract *INetworkCaller // Generic read-only contract binding to access the raw methods on
}

// INetworkTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type INetworkTransactorRaw struct {
	Contract *INetworkTransactor // Generic write-only contract binding to access the raw methods on
}

// NewINetwork creates a new instance of INetwork, bound to a specific deployed contract.
func NewINetwork(address common.Address, backend bind.ContractBackend) (*INetwork, error) {
	contract, err := bindINetwork(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &INetwork{INetworkCaller: INetworkCaller{contract: contract}, INetworkTransactor: INetworkTransactor{contract: contract}, INetworkFilterer: INetworkFilterer{contract: contract}}, nil
}

// NewINetworkCaller creates a new read-only instance of INetwork, bound to a specific deployed contract.
func NewINetworkCaller(address common.Address, caller bind.ContractCaller) (*INetworkCaller, error) {
	contract, err := bindINetwork(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &INetworkCaller{contract: contract}, nil
}

// NewINetworkTransactor creates a new write-only instance of INetwork, bound to a specific deployed contract.
func NewINetworkTransactor(address common.Address, transactor bind.ContractTransactor) (*INetworkTransactor, error) {
	contract, err := bindINetwork(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &INetworkTransactor{contract: contract}, nil
}

// NewINetworkFilterer creates a new log filterer instance of INetwork, bound to a specific deployed contract.
func NewINetworkFilterer(address common.Address, filterer bind.ContractFilterer) (*INetworkFilterer, error) {
	contract, err := bindINetwork(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &INetworkFilterer{contract: contract}, nil
}

// bindINetwork binds a generic wrapper to an already deployed contract.
func bindINetwork(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := INetworkMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_INetwork *INetworkRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _INetwork.Contract.INetworkCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_INetwork *INetworkRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _INetwork.Contract.INetworkTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_INetwork *INetworkRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _INetwork.Contract.INetworkTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_INetwork *INetworkCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _INetwork.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_INetwork *INetworkTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _INetwork.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_INetwork *INetworkTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _INetwork.Contract.contract.Transact(opts, method, params...)
}

// METADATAURIUPDATEROLE is a free data retrieval call binding the contract method 0x86b18753.
//
// Solidity: function METADATA_URI_UPDATE_ROLE() view returns(bytes32)
func (_INetwork *INetworkCaller) METADATAURIUPDATEROLE(opts *bind.CallOpts) ([32]byte, error) {
	var out []interface{}
	err := _INetwork.contract.Call(opts, &out, "METADATA_URI_UPDATE_ROLE")

	if err != nil {
		return *new([32]byte), err
	}

	out0 := *abi.ConvertType(out[0], new([32]byte)).(*[32]byte)

	return out0, err

}

// METADATAURIUPDATEROLE is a free data retrieval call binding the contract method 0x86b18753.
//
// Solidity: function METADATA_URI_UPDATE_ROLE() view returns(bytes32)
func (_INetwork *INetworkSession) METADATAURIUPDATEROLE() ([32]byte, error) {
	return _INetwork.Contract.METADATAURIUPDATEROLE(&_INetwork.CallOpts)
}

// METADATAURIUPDATEROLE is a free data retrieval call binding the contract method 0x86b18753.
//
// Solidity: function METADATA_URI_UPDATE_ROLE() view returns(bytes32)
func (_INetwork *INetworkCallerSession) METADATAURIUPDATEROLE() ([32]byte, error) {
	return _INetwork.Contract.METADATAURIUPDATEROLE(&_INetwork.CallOpts)
}

// NAMEUPDATEROLE is a free data retrieval call binding the contract method 0x2f90bfbf.
//
// Solidity: function NAME_UPDATE_ROLE() view returns(bytes32)
func (_INetwork *INetworkCaller) NAMEUPDATEROLE(opts *bind.CallOpts) ([32]byte, error) {
	var out []interface{}
	err := _INetwork.contract.Call(opts, &out, "NAME_UPDATE_ROLE")

	if err != nil {
		return *new([32]byte), err
	}

	out0 := *abi.ConvertType(out[0], new([32]byte)).(*[32]byte)

	return out0, err

}

// NAMEUPDATEROLE is a free data retrieval call binding the contract method 0x2f90bfbf.
//
// Solidity: function NAME_UPDATE_ROLE() view returns(bytes32)
func (_INetwork *INetworkSession) NAMEUPDATEROLE() ([32]byte, error) {
	return _INetwork.Contract.NAMEUPDATEROLE(&_INetwork.CallOpts)
}

// NAMEUPDATEROLE is a free data retrieval call binding the contract method 0x2f90bfbf.
//
// Solidity: function NAME_UPDATE_ROLE() view returns(bytes32)
func (_INetwork *INetworkCallerSession) NAMEUPDATEROLE() ([32]byte, error) {
	return _INetwork.Contract.NAMEUPDATEROLE(&_INetwork.CallOpts)
}

// NETWORKMIDDLEWARESERVICE is a free data retrieval call binding the contract method 0x2c9d45b3.
//
// Solidity: function NETWORK_MIDDLEWARE_SERVICE() view returns(address)
func (_INetwork *INetworkCaller) NETWORKMIDDLEWARESERVICE(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _INetwork.contract.Call(opts, &out, "NETWORK_MIDDLEWARE_SERVICE")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// NETWORKMIDDLEWARESERVICE is a free data retrieval call binding the contract method 0x2c9d45b3.
//
// Solidity: function NETWORK_MIDDLEWARE_SERVICE() view returns(address)
func (_INetwork *INetworkSession) NETWORKMIDDLEWARESERVICE() (common.Address, error) {
	return _INetwork.Contract.NETWORKMIDDLEWARESERVICE(&_INetwork.CallOpts)
}

// NETWORKMIDDLEWARESERVICE is a free data retrieval call binding the contract method 0x2c9d45b3.
//
// Solidity: function NETWORK_MIDDLEWARE_SERVICE() view returns(address)
func (_INetwork *INetworkCallerSession) NETWORKMIDDLEWARESERVICE() (common.Address, error) {
	return _INetwork.Contract.NETWORKMIDDLEWARESERVICE(&_INetwork.CallOpts)
}

// NETWORKREGISTRY is a free data retrieval call binding the contract method 0xc0cd7c3e.
//
// Solidity: function NETWORK_REGISTRY() view returns(address)
func (_INetwork *INetworkCaller) NETWORKREGISTRY(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _INetwork.contract.Call(opts, &out, "NETWORK_REGISTRY")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// NETWORKREGISTRY is a free data retrieval call binding the contract method 0xc0cd7c3e.
//
// Solidity: function NETWORK_REGISTRY() view returns(address)
func (_INetwork *INetworkSession) NETWORKREGISTRY() (common.Address, error) {
	return _INetwork.Contract.NETWORKREGISTRY(&_INetwork.CallOpts)
}

// NETWORKREGISTRY is a free data retrieval call binding the contract method 0xc0cd7c3e.
//
// Solidity: function NETWORK_REGISTRY() view returns(address)
func (_INetwork *INetworkCallerSession) NETWORKREGISTRY() (common.Address, error) {
	return _INetwork.Contract.NETWORKREGISTRY(&_INetwork.CallOpts)
}

// GetMinDelay is a free data retrieval call binding the contract method 0xebffd16b.
//
// Solidity: function getMinDelay(address target, bytes data) view returns(uint256)
func (_INetwork *INetworkCaller) GetMinDelay(opts *bind.CallOpts, target common.Address, data []byte) (*big.Int, error) {
	var out []interface{}
	err := _INetwork.contract.Call(opts, &out, "getMinDelay", target, data)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetMinDelay is a free data retrieval call binding the contract method 0xebffd16b.
//
// Solidity: function getMinDelay(address target, bytes data) view returns(uint256)
func (_INetwork *INetworkSession) GetMinDelay(target common.Address, data []byte) (*big.Int, error) {
	return _INetwork.Contract.GetMinDelay(&_INetwork.CallOpts, target, data)
}

// GetMinDelay is a free data retrieval call binding the contract method 0xebffd16b.
//
// Solidity: function getMinDelay(address target, bytes data) view returns(uint256)
func (_INetwork *INetworkCallerSession) GetMinDelay(target common.Address, data []byte) (*big.Int, error) {
	return _INetwork.Contract.GetMinDelay(&_INetwork.CallOpts, target, data)
}

// MetadataURI is a free data retrieval call binding the contract method 0x03ee438c.
//
// Solidity: function metadataURI() view returns(string)
func (_INetwork *INetworkCaller) MetadataURI(opts *bind.CallOpts) (string, error) {
	var out []interface{}
	err := _INetwork.contract.Call(opts, &out, "metadataURI")

	if err != nil {
		return *new(string), err
	}

	out0 := *abi.ConvertType(out[0], new(string)).(*string)

	return out0, err

}

// MetadataURI is a free data retrieval call binding the contract method 0x03ee438c.
//
// Solidity: function metadataURI() view returns(string)
func (_INetwork *INetworkSession) MetadataURI() (string, error) {
	return _INetwork.Contract.MetadataURI(&_INetwork.CallOpts)
}

// MetadataURI is a free data retrieval call binding the contract method 0x03ee438c.
//
// Solidity: function metadataURI() view returns(string)
func (_INetwork *INetworkCallerSession) MetadataURI() (string, error) {
	return _INetwork.Contract.MetadataURI(&_INetwork.CallOpts)
}

// Name is a free data retrieval call binding the contract method 0x06fdde03.
//
// Solidity: function name() view returns(string)
func (_INetwork *INetworkCaller) Name(opts *bind.CallOpts) (string, error) {
	var out []interface{}
	err := _INetwork.contract.Call(opts, &out, "name")

	if err != nil {
		return *new(string), err
	}

	out0 := *abi.ConvertType(out[0], new(string)).(*string)

	return out0, err

}

// Name is a free data retrieval call binding the contract method 0x06fdde03.
//
// Solidity: function name() view returns(string)
func (_INetwork *INetworkSession) Name() (string, error) {
	return _INetwork.Contract.Name(&_INetwork.CallOpts)
}

// Name is a free data retrieval call binding the contract method 0x06fdde03.
//
// Solidity: function name() view returns(string)
func (_INetwork *INetworkCallerSession) Name() (string, error) {
	return _INetwork.Contract.Name(&_INetwork.CallOpts)
}

// Initialize is a paid mutator transaction binding the contract method 0x6f8d7599.
//
// Solidity: function initialize((uint256,(address,bytes4,uint256)[],address[],address[],string,string,address,address,address) networkInitParams) returns()
func (_INetwork *INetworkTransactor) Initialize(opts *bind.TransactOpts, networkInitParams INetworkNetworkInitParams) (*types.Transaction, error) {
	return _INetwork.contract.Transact(opts, "initialize", networkInitParams)
}

// Initialize is a paid mutator transaction binding the contract method 0x6f8d7599.
//
// Solidity: function initialize((uint256,(address,bytes4,uint256)[],address[],address[],string,string,address,address,address) networkInitParams) returns()
func (_INetwork *INetworkSession) Initialize(networkInitParams INetworkNetworkInitParams) (*types.Transaction, error) {
	return _INetwork.Contract.Initialize(&_INetwork.TransactOpts, networkInitParams)
}

// Initialize is a paid mutator transaction binding the contract method 0x6f8d7599.
//
// Solidity: function initialize((uint256,(address,bytes4,uint256)[],address[],address[],string,string,address,address,address) networkInitParams) returns()
func (_INetwork *INetworkTransactorSession) Initialize(networkInitParams INetworkNetworkInitParams) (*types.Transaction, error) {
	return _INetwork.Contract.Initialize(&_INetwork.TransactOpts, networkInitParams)
}

// SetMaxNetworkLimit is a paid mutator transaction binding the contract method 0x6773522c.
//
// Solidity: function setMaxNetworkLimit(address delegator, uint96 subnetworkId, uint256 maxNetworkLimit) returns()
func (_INetwork *INetworkTransactor) SetMaxNetworkLimit(opts *bind.TransactOpts, delegator common.Address, subnetworkId *big.Int, maxNetworkLimit *big.Int) (*types.Transaction, error) {
	return _INetwork.contract.Transact(opts, "setMaxNetworkLimit", delegator, subnetworkId, maxNetworkLimit)
}

// SetMaxNetworkLimit is a paid mutator transaction binding the contract method 0x6773522c.
//
// Solidity: function setMaxNetworkLimit(address delegator, uint96 subnetworkId, uint256 maxNetworkLimit) returns()
func (_INetwork *INetworkSession) SetMaxNetworkLimit(delegator common.Address, subnetworkId *big.Int, maxNetworkLimit *big.Int) (*types.Transaction, error) {
	return _INetwork.Contract.SetMaxNetworkLimit(&_INetwork.TransactOpts, delegator, subnetworkId, maxNetworkLimit)
}

// SetMaxNetworkLimit is a paid mutator transaction binding the contract method 0x6773522c.
//
// Solidity: function setMaxNetworkLimit(address delegator, uint96 subnetworkId, uint256 maxNetworkLimit) returns()
func (_INetwork *INetworkTransactorSession) SetMaxNetworkLimit(delegator common.Address, subnetworkId *big.Int, maxNetworkLimit *big.Int) (*types.Transaction, error) {
	return _INetwork.Contract.SetMaxNetworkLimit(&_INetwork.TransactOpts, delegator, subnetworkId, maxNetworkLimit)
}

// UpdateDelay is a paid mutator transaction binding the contract method 0x6a63fa02.
//
// Solidity: function updateDelay(address target, bytes4 selector, bool enabled, uint256 newDelay) returns()
func (_INetwork *INetworkTransactor) UpdateDelay(opts *bind.TransactOpts, target common.Address, selector [4]byte, enabled bool, newDelay *big.Int) (*types.Transaction, error) {
	return _INetwork.contract.Transact(opts, "updateDelay", target, selector, enabled, newDelay)
}

// UpdateDelay is a paid mutator transaction binding the contract method 0x6a63fa02.
//
// Solidity: function updateDelay(address target, bytes4 selector, bool enabled, uint256 newDelay) returns()
func (_INetwork *INetworkSession) UpdateDelay(target common.Address, selector [4]byte, enabled bool, newDelay *big.Int) (*types.Transaction, error) {
	return _INetwork.Contract.UpdateDelay(&_INetwork.TransactOpts, target, selector, enabled, newDelay)
}

// UpdateDelay is a paid mutator transaction binding the contract method 0x6a63fa02.
//
// Solidity: function updateDelay(address target, bytes4 selector, bool enabled, uint256 newDelay) returns()
func (_INetwork *INetworkTransactorSession) UpdateDelay(target common.Address, selector [4]byte, enabled bool, newDelay *big.Int) (*types.Transaction, error) {
	return _INetwork.Contract.UpdateDelay(&_INetwork.TransactOpts, target, selector, enabled, newDelay)
}

// UpdateMetadataURI is a paid mutator transaction binding the contract method 0x53fd3e81.
//
// Solidity: function updateMetadataURI(string metadataURI) returns()
func (_INetwork *INetworkTransactor) UpdateMetadataURI(opts *bind.TransactOpts, metadataURI string) (*types.Transaction, error) {
	return _INetwork.contract.Transact(opts, "updateMetadataURI", metadataURI)
}

// UpdateMetadataURI is a paid mutator transaction binding the contract method 0x53fd3e81.
//
// Solidity: function updateMetadataURI(string metadataURI) returns()
func (_INetwork *INetworkSession) UpdateMetadataURI(metadataURI string) (*types.Transaction, error) {
	return _INetwork.Contract.UpdateMetadataURI(&_INetwork.TransactOpts, metadataURI)
}

// UpdateMetadataURI is a paid mutator transaction binding the contract method 0x53fd3e81.
//
// Solidity: function updateMetadataURI(string metadataURI) returns()
func (_INetwork *INetworkTransactorSession) UpdateMetadataURI(metadataURI string) (*types.Transaction, error) {
	return _INetwork.Contract.UpdateMetadataURI(&_INetwork.TransactOpts, metadataURI)
}

// UpdateName is a paid mutator transaction binding the contract method 0x84da92a7.
//
// Solidity: function updateName(string name) returns()
func (_INetwork *INetworkTransactor) UpdateName(opts *bind.TransactOpts, name string) (*types.Transaction, error) {
	return _INetwork.contract.Transact(opts, "updateName", name)
}

// UpdateName is a paid mutator transaction binding the contract method 0x84da92a7.
//
// Solidity: function updateName(string name) returns()
func (_INetwork *INetworkSession) UpdateName(name string) (*types.Transaction, error) {
	return _INetwork.Contract.UpdateName(&_INetwork.TransactOpts, name)
}

// UpdateName is a paid mutator transaction binding the contract method 0x84da92a7.
//
// Solidity: function updateName(string name) returns()
func (_INetwork *INetworkTransactorSession) UpdateName(name string) (*types.Transaction, error) {
	return _INetwork.Contract.UpdateName(&_INetwork.TransactOpts, name)
}

// INetworkMetadataURISetIterator is returned from FilterMetadataURISet and is used to iterate over the raw logs and unpacked data for MetadataURISet events raised by the INetwork contract.
type INetworkMetadataURISetIterator struct {
	Event *INetworkMetadataURISet // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *INetworkMetadataURISetIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(INetworkMetadataURISet)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(INetworkMetadataURISet)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *INetworkMetadataURISetIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *INetworkMetadataURISetIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// INetworkMetadataURISet represents a MetadataURISet event raised by the INetwork contract.
type INetworkMetadataURISet struct {
	MetadataURI string
	Raw         types.Log // Blockchain specific contextual infos
}

// FilterMetadataURISet is a free log retrieval operation binding the contract event 0x307edb14d46e43e3a7232886d692798e4129f8bb711ca4ce6cf43e2c55fc8e96.
//
// Solidity: event MetadataURISet(string metadataURI)
func (_INetwork *INetworkFilterer) FilterMetadataURISet(opts *bind.FilterOpts) (*INetworkMetadataURISetIterator, error) {

	logs, sub, err := _INetwork.contract.FilterLogs(opts, "MetadataURISet")
	if err != nil {
		return nil, err
	}
	return &INetworkMetadataURISetIterator{contract: _INetwork.contract, event: "MetadataURISet", logs: logs, sub: sub}, nil
}

// WatchMetadataURISet is a free log subscription operation binding the contract event 0x307edb14d46e43e3a7232886d692798e4129f8bb711ca4ce6cf43e2c55fc8e96.
//
// Solidity: event MetadataURISet(string metadataURI)
func (_INetwork *INetworkFilterer) WatchMetadataURISet(opts *bind.WatchOpts, sink chan<- *INetworkMetadataURISet) (event.Subscription, error) {

	logs, sub, err := _INetwork.contract.WatchLogs(opts, "MetadataURISet")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(INetworkMetadataURISet)
				if err := _INetwork.contract.UnpackLog(event, "MetadataURISet", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseMetadataURISet is a log parse operation binding the contract event 0x307edb14d46e43e3a7232886d692798e4129f8bb711ca4ce6cf43e2c55fc8e96.
//
// Solidity: event MetadataURISet(string metadataURI)
func (_INetwork *INetworkFilterer) ParseMetadataURISet(log types.Log) (*INetworkMetadataURISet, error) {
	event := new(INetworkMetadataURISet)
	if err := _INetwork.contract.UnpackLog(event, "MetadataURISet", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// INetworkMinDelayChangeIterator is returned from FilterMinDelayChange and is used to iterate over the raw logs and unpacked data for MinDelayChange events raised by the INetwork contract.
type INetworkMinDelayChangeIterator struct {
	Event *INetworkMinDelayChange // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *INetworkMinDelayChangeIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(INetworkMinDelayChange)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(INetworkMinDelayChange)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *INetworkMinDelayChangeIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *INetworkMinDelayChangeIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// INetworkMinDelayChange represents a MinDelayChange event raised by the INetwork contract.
type INetworkMinDelayChange struct {
	Target           common.Address
	Selector         [4]byte
	OldEnabledStatus bool
	OldDelay         *big.Int
	NewEnabledStatus bool
	NewDelay         *big.Int
	Raw              types.Log // Blockchain specific contextual infos
}

// FilterMinDelayChange is a free log retrieval operation binding the contract event 0x93fabeab651ad4c07682ff2702edcdcb0459c81c6c312b81d4cf9538ee7d76c7.
//
// Solidity: event MinDelayChange(address indexed target, bytes4 indexed selector, bool oldEnabledStatus, uint256 oldDelay, bool newEnabledStatus, uint256 newDelay)
func (_INetwork *INetworkFilterer) FilterMinDelayChange(opts *bind.FilterOpts, target []common.Address, selector [][4]byte) (*INetworkMinDelayChangeIterator, error) {

	var targetRule []interface{}
	for _, targetItem := range target {
		targetRule = append(targetRule, targetItem)
	}
	var selectorRule []interface{}
	for _, selectorItem := range selector {
		selectorRule = append(selectorRule, selectorItem)
	}

	logs, sub, err := _INetwork.contract.FilterLogs(opts, "MinDelayChange", targetRule, selectorRule)
	if err != nil {
		return nil, err
	}
	return &INetworkMinDelayChangeIterator{contract: _INetwork.contract, event: "MinDelayChange", logs: logs, sub: sub}, nil
}

// WatchMinDelayChange is a free log subscription operation binding the contract event 0x93fabeab651ad4c07682ff2702edcdcb0459c81c6c312b81d4cf9538ee7d76c7.
//
// Solidity: event MinDelayChange(address indexed target, bytes4 indexed selector, bool oldEnabledStatus, uint256 oldDelay, bool newEnabledStatus, uint256 newDelay)
func (_INetwork *INetworkFilterer) WatchMinDelayChange(opts *bind.WatchOpts, sink chan<- *INetworkMinDelayChange, target []common.Address, selector [][4]byte) (event.Subscription, error) {

	var targetRule []interface{}
	for _, targetItem := range target {
		targetRule = append(targetRule, targetItem)
	}
	var selectorRule []interface{}
	for _, selectorItem := range selector {
		selectorRule = append(selectorRule, selectorItem)
	}

	logs, sub, err := _INetwork.contract.WatchLogs(opts, "MinDelayChange", targetRule, selectorRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(INetworkMinDelayChange)
				if err := _INetwork.contract.UnpackLog(event, "MinDelayChange", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseMinDelayChange is a log parse operation binding the contract event 0x93fabeab651ad4c07682ff2702edcdcb0459c81c6c312b81d4cf9538ee7d76c7.
//
// Solidity: event MinDelayChange(address indexed target, bytes4 indexed selector, bool oldEnabledStatus, uint256 oldDelay, bool newEnabledStatus, uint256 newDelay)
func (_INetwork *INetworkFilterer) ParseMinDelayChange(log types.Log) (*INetworkMinDelayChange, error) {
	event := new(INetworkMinDelayChange)
	if err := _INetwork.contract.UnpackLog(event, "MinDelayChange", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// INetworkNameSetIterator is returned from FilterNameSet and is used to iterate over the raw logs and unpacked data for NameSet events raised by the INetwork contract.
type INetworkNameSetIterator struct {
	Event *INetworkNameSet // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *INetworkNameSetIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(INetworkNameSet)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(INetworkNameSet)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *INetworkNameSetIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *INetworkNameSetIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// INetworkNameSet represents a NameSet event raised by the INetwork contract.
type INetworkNameSet struct {
	Name string
	Raw  types.Log // Blockchain specific contextual infos
}

// FilterNameSet is a free log retrieval operation binding the contract event 0x13c98778b0c1a086bb98d7f1986e15788b5d3a1ad4c492e1d78f1c4cc51c20cf.
//
// Solidity: event NameSet(string name)
func (_INetwork *INetworkFilterer) FilterNameSet(opts *bind.FilterOpts) (*INetworkNameSetIterator, error) {

	logs, sub, err := _INetwork.contract.FilterLogs(opts, "NameSet")
	if err != nil {
		return nil, err
	}
	return &INetworkNameSetIterator{contract: _INetwork.contract, event: "NameSet", logs: logs, sub: sub}, nil
}

// WatchNameSet is a free log subscription operation binding the contract event 0x13c98778b0c1a086bb98d7f1986e15788b5d3a1ad4c492e1d78f1c4cc51c20cf.
//
// Solidity: event NameSet(string name)
func (_INetwork *INetworkFilterer) WatchNameSet(opts *bind.WatchOpts, sink chan<- *INetworkNameSet) (event.Subscription, error) {

	logs, sub, err := _INetwork.contract.WatchLogs(opts, "NameSet")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(INetworkNameSet)
				if err := _INetwork.contract.UnpackLog(event, "NameSet", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseNameSet is a log parse operation binding the contract event 0x13c98778b0c1a086bb98d7f1986e15788b5d3a1ad4c492e1d78f1c4cc51c20cf.
//
// Solidity: event NameSet(string name)
func (_INetwork *INetworkFilterer) ParseNameSet(log types.Log) (*INetworkNameSet, error) {
	event := new(INetworkNameSet)
	if err := _INetwork.contract.UnpackLog(event, "NameSet", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
