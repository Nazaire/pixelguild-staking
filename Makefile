.PHONY: install test-keys build start test clean-test-keys stop

TEST_KEY := $(shell solana-keygen pubkey ./tests/test-key.json)

all: install test-keys build start test clean-test-keys stop

install:
	yarn install

test-keys:
	LC_ALL=C find programs src -type f -exec sed -i '' -e "s/CYUGdQhsWCKXTWgbyuybhRfPTshxneywND8KnHeMfwQe/$$(solana-keygen pubkey ./target/deploy/cardinal_stake_pool-keypair.json)/g" {} +
	LC_ALL=C find programs src -type f -exec sed -i '' -e "s/9h3kHWEExHGyUyEtDhSgRufYqM3BdG4THKcKCny4jZuc/$$(solana-keygen pubkey ./target/deploy/cardinal_reward_distributor-keypair.json)/g" {} +

build:
	anchor build
	yarn idl:generate

start:
	solana-test-validator --url https://api.devnet.solana.com \
		--clone metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s --clone PwDiXFxQsGra4sFFTT8r1QWRMd4vfumiWC1jfWNfdYT \
		--clone 39xubSermwXqcSPu2qEHSspGVmsVZYBnA8RbFqhMLbFK --clone ojLGErfqghuAqpJXE1dguXF7kKfvketCEeah8ig6GU3 \
		--bpf-program ./target/deploy/cardinal_stake_pool-keypair.json ./target/deploy/cardinal_stake_pool.so \
		--bpf-program ./target/deploy/cardinal_reward_distributor-keypair.json ./target/deploy/cardinal_reward_distributor.so \
		--reset --quiet & echo $$!
	sleep 10
	solana-keygen pubkey ./tests/test-key.json
	solana airdrop 1000 $(TEST_KEY) --url http://localhost:8899

test:
	anchor test --skip-local-validator --skip-build --skip-deploy --provider.cluster localnet

clean-test-keys:
	LC_ALL=C find programs src -type f -exec sed -i '' -e "s/$$(solana-keygen pubkey ./target/deploy/cardinal_stake_pool-keypair.json)/CYUGdQhsWCKXTWgbyuybhRfPTshxneywND8KnHeMfwQe/g" {} +
	LC_ALL=C find programs src -type f -exec sed -i '' -e "s/$$(solana-keygen pubkey ./target/deploy/cardinal_reward_distributor-keypair.json)/9h3kHWEExHGyUyEtDhSgRufYqM3BdG4THKcKCny4jZuc/g" {} +

stop:
	pkill solana-test-validator