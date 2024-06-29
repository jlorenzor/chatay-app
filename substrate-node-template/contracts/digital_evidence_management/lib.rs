#![cfg_attr(not(feature = "std"), no_std)]

use ink_lang as ink;

#[ink::contract]
mod digital_evidence_management {
    use ink_storage::{
        collections::HashMap as StorageHashMap,
        traits::{PackedLayout, SpreadLayout},
    };

    #[derive(scale::Encode, scale::Decode, Clone, SpreadLayout, PackedLayout)]
    #[cfg_attr(
        feature = "std",
        derive(scale_info::TypeInfo, ink_storage::traits::StorageLayout)
    )]
    pub struct DigitalEvidence {
        incident_id: u32,
        submitter: AccountId,
        metadata: Vec<u8>,
        evidence_hash: [u8; 32],
    }

    #[ink(storage)]
    pub struct DigitalEvidenceManagement {
        evidences: StorageHashMap<u32, DigitalEvidence>,
        evidence_count: u32,
    }

    impl DigitalEvidenceManagement {
        #[ink(constructor)]
        pub fn new() -> Self {
            Self {
                evidences: StorageHashMap::new(),
                evidence_count: 0,
            }
        }

        #[ink(message)]
        pub fn submit_evidence(&mut self, incident_id: u32, metadata: Vec<u8>, evidence_hash: [u8; 32]) -> bool {
            let submitter = self.env().caller();
            let evidence = DigitalEvidence {
                incident_id,
                submitter,
                metadata,
                evidence_hash,
            };
            self.evidence_count += 1;
            self.evidences.insert(self.evidence_count, evidence);
            true
        }

        #[ink(message)]
        pub fn query_evidence(&self, evidence_id: u32) -> Option<DigitalEvidence> {
            self.evidences.get(&evidence_id).cloned()
        }

        #[ink(message)]
        pub fn get_evidence_count(&self) -> u32 {
            self.evidence_count
        }
    }

    #[cfg(test)]
    mod tests {
        use super::*;
        use ink_lang as ink;

        #[ink::test]
        fn submit_and_query_evidence_works() {
            let mut contract = DigitalEvidenceManagement::new();
            let incident_id = 1;
            let metadata = vec![1, 2, 3, 4];
            let evidence_hash = [0x42; 32];

            assert!(contract.submit_evidence(incident_id, metadata.clone(), evidence_hash));
            assert_eq!(contract.get_evidence_count(), 1);

            let retrieved_evidence = contract.query_evidence(1).unwrap();
            assert_eq!(retrieved_evidence.incident_id, incident_id);
            assert_eq!(retrieved_evidence.metadata, metadata);
            assert_eq!(retrieved_evidence.evidence_hash, evidence_hash);
        }
    }
}
