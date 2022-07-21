from brownie import Price_Control, TestExchange, accounts


def deploy_mock():
    account = accounts[0]
    price_control = Price_Control.deploy({"from": account})
    test_exchange = TestExchange.deploy(price_control.address, {"from": account})
    return test_exchange
