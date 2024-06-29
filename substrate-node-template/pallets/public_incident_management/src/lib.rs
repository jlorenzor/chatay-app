#![cfg_attr(not(feature = "std"), no_std)]

use frame_support::{decl_module, decl_storage, decl_event, decl_error, dispatch, traits::Get};
use frame_system::ensure_signed;
use sp_std::prelude::*;

#[cfg(test)]
mod mock;

#[cfg(test)]
mod tests;

pub trait Config: frame_system::Config {
    type Event: From<Event<Self>> + Into<<Self as frame_system::Config>::Event>;
}

#[derive(Encode, Decode, Clone, PartialEq, Eq, RuntimeDebug)]
pub struct PublicIncident<AccountId> {
    reporter: AccountId,
    description: Vec<u8>,
    location: Vec<u8>,
    timestamp: u64,
    status: IncidentStatus,
    category: IncidentCategory,
}

#[derive(Encode, Decode, Clone, PartialEq, Eq, RuntimeDebug)]
pub enum IncidentStatus {
    Reported,
    UnderReview,
    InProgress,
    Resolved,
    Closed,
}

#[derive(Encode, Decode, Clone, PartialEq, Eq, RuntimeDebug)]
pub enum IncidentCategory {
    Infrastructure,
    PublicSafety,
    EnvironmentalIssue,
    CommunityServices,
    Other,
}

decl_storage! {
    trait Store for Module<T: Config> as PublicIncidentManagement {
        Incidents get(fn incidents): map hasher(blake2_128_concat) u32 => Option<PublicIncident<T::AccountId>>;
        IncidentCount get(fn incident_count): u32;
    }
}

decl_event!(
    pub enum Event<T> where AccountId = <T as frame_system::Config>::AccountId {
        IncidentReported(u32, AccountId),
        IncidentStatusUpdated(u32, IncidentStatus),
    }
);

decl_error! {
    pub enum Error for Module<T: Config> {
        IncidentNotFound,
        NotAuthorized,
    }
}

decl_module! {
    pub struct Module<T: Config> for enum Call where origin: T::Origin {
        type Error = Error<T>;

        fn deposit_event() = default;

        #[weight = 10_000]
        pub fn report_incident(origin, description: Vec<u8>, location: Vec<u8>, category: IncidentCategory) -> dispatch::DispatchResult {
            let reporter = ensure_signed(origin)?;

            let incident_id = IncidentCount::get();
            let incident = PublicIncident {
                reporter: reporter.clone(),
                description,
                location,
                timestamp: <frame_system::Module<T>>::block_number().saturated_into::<u64>(),
                status: IncidentStatus::Reported,
                category,
            };

            Incidents::insert(incident_id, incident);
            IncidentCount::mutate(|count| *count += 1);

            Self::deposit_event(RawEvent::IncidentReported(incident_id, reporter));
            Ok(())
        }

        #[weight = 10_000]
        pub fn update_incident_status(origin, incident_id: u32, new_status: IncidentStatus) -> dispatch::DispatchResult {
            let who = ensure_signed(origin)?;

            Incidents::mutate(incident_id, |incident| {
                if let Some(ref mut i) = incident {
                    i.status = new_status.clone();
                    Self::deposit_event(RawEvent::IncidentStatusUpdated(incident_id, new_status));
                    Ok(())
                } else {
                    Err(Error::<T>::IncidentNotFound)?
                }
            })
        }
    }
}
