function hl
    hledger \
                  -f ~/Documents/finance/hledger/actual-transactions.ledger \
                  -f ~/Documents/finance/hledger/plan.ledger \
                  $argv
end
