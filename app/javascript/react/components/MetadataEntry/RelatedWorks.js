import React, {useState} from 'react';
import axios from 'axios';
import PropTypes from 'prop-types';
import RelatedWorkForm from './RelatedWorkForm';
import {showSavedMsg, showSavingMsg} from '../../../lib/utils';

function RelatedWorks(
  {
    resourceId,
    relatedIdentifiers,
    workTypes,
  },
) {
  const csrf = document.querySelector("meta[name='csrf-token']")?.getAttribute('content');

  const blankRelated = {
    related_identifier: '',
    related_identifier_type: 'doi',
    relation_type: 'iscitedby',
    resource_id: resourceId,
    work_type: 'article',
  };

  const [works, setWorks] = useState(relatedIdentifiers);

  const addNewWork = () => {
    console.log(`${(new Date()).toISOString()}: Adding Related Works`);
    const contribJson = {
      authenticity_token: csrf,
      stash_datacite_related_identifier: blankRelated,
    };

    axios.post(
      '/stash_datacite/related_identifiers/create',
      contribJson,
      {headers: {'Content-Type': 'application/json; charset=utf-8', Accept: 'application/json'}},
    )
      .then((data) => {
        if (data.status !== 200) {
          console.log("couldn't add new relatedWork to the remote server");
        }
        setWorks((prevState) => [...prevState, data.data]);
      });
  };

  if (works.length < 1) {
    addNewWork();
  }

  const removeItem = (id) => {
    console.log(`${(new Date()).toISOString()}: deleting relatedWork ${id}`);
    const trueDelPath = `/stash_datacite/related_identifiers/${id}/delete`;
    showSavingMsg();

    const submitVals = {
      authenticity_token: csrf,
    };
    axios.delete(trueDelPath, {
      data: submitVals,
      headers: {'Content-Type': 'application/json; charset=utf-8', Accept: 'application/json'},
    })
      .then((data) => {
        if (data.status !== 200) {
          console.log('Response failure not a 200 response from related works deletion');
        } else {
          console.log('deleted from related works');
        }
        showSavedMsg();
      });
    setWorks((prevState) => prevState.filter((item) => (item.id !== id)));
  };

  // update the work in the list from old to new values
  const updateWork = (updatedRelatedId) => {
    // replace item in the funder list if it has changed
    setWorks((prevState) => prevState.map((tempRel) => (updatedRelatedId.id === tempRel.id ? updatedRelatedId : tempRel)));
  };

  return (
    <fieldset className="c-fieldset">
      <legend className="c-fieldset__legend">
        <span className="c-input__hint">
          Are there any preprints, articles, datasets, software packages, or supplemental
          information that have resulted from or are related to this Data Publication?
        </span>
      </legend>
      <div className="replaceme-related-works">
        {works.map((relatedIdentifier) => (
          <RelatedWorkForm
            key={relatedIdentifier.id}
            relatedIdentifier={relatedIdentifier}
            workTypes={workTypes}
            removeFunction={removeItem}
            updateWork={updateWork}
          />
        ))}
      </div>
      {/* eslint-disable jsx-a11y/anchor-is-valid */}
      <a
        href="#"
        className="o-button__add"
        role="button"
        onClick={(e) => {
          e.preventDefault();
          addNewWork();
        }}
      >
        add another related work
      </a>
      {/* eslint-enable jsx-a11y/anchor-is-valid */}
    </fieldset>
  );
}

export default RelatedWorks;

RelatedWorks.propTypes = {
  resourceId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  relatedIdentifiers: PropTypes.array.isRequired,
  workTypes: PropTypes.array.isRequired,
};
