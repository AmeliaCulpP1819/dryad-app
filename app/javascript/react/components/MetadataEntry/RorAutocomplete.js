import React, {useEffect, useRef, useState} from 'react';
import axios from 'axios';
import PropTypes from 'prop-types';
import GenericNameIdAutocomplete from './GenericNameIdAutocomplete';

export default function RorAutocomplete({
  formRef, acText, setAcText, acID, setAcID, controlOptions,
}) {
  // control options: htmlId, labelText, isRequired (t/f)

  // in order to use this component, we need to track the state of the autocomplete text and the autocomplete id
  // https://www.freecodecamp.org/news/what-is-lifting-state-up-in-react/ is a better functional example than the react docs.
  // also tracking "autoBlurred" since we need to know when things exit to trigger form resubmission or sending to server.
  const prevText = useRef(acText);
  const prevID = useRef(acID);
  const [autoBlurred, setAutoBlurred] = useState(false);

  // do something when blurring from the autocomplete, passed up here, probably want to save on blur, but save
  // action may be different depending on autocomplete context inside another form or may save directly.
  useEffect(() => {
    if (autoBlurred) {
      if (!acText) {
        setAcID('');
      }
      /* it seems like the current way for this to work within authors is to add elements named
            "author[affiliation][long_name]" and "author[affiliation][ror_id]" that have correct values and resubmit
            the form.
           */
      if (prevText.current !== acText || prevID.current !== acID) {
        // from the ref, submit the Formik form above me
        formRef.current.handleSubmit();
      }
      prevText.current = acText;
      prevID.current = acID;
      setAutoBlurred(false);
    }
  }, [autoBlurred]);

  /* supplyLookupList returns a promise that will supply a list of js objects that
     can have their properties used to create the autocomplete list.
     It is required to be passed in so we can get lists from various data sources which may vary across different
     autocompletes for a generic case.
   */
  function supplyLookupList(qt) {
    return axios.get('/stash_datacite/affiliations/autocomplete', {
      params: {query: qt},
      headers: {'Content-Type': 'application/json; charset=utf-8', Accept: 'application/json'},
    })
      .then((data) => {
        if (data.status !== 200) {
          return [];
          // raise an error here if we want to catch it and display something to user or do something else
        }
        return data.data;
      });
  }

  // Given a js object from list (supplyLookupList above) it returns the string name
  function nameFunc(item) {
    return (item?.name || '');
  }

  // Given a js object from list (supplyLookupList above) it returns the unique identifier
  function idFunc(item) {
    return item.id;
  }

  /* eslint-disable react/jsx-no-bind */
  // I'm passing in functions for getting name, id and lookup list.  None require any state from this component and are static functions
  // eslint hates it, but what's the point of higher order functions or passing functions to separate concerns if you can't use it?
  // I don't think this is actually a problem and if it causes re-loading of functions, IDK what a good alternative is.
  // The information I can find regarding why not to pass a function through props in react is conflicting and unclear and
  // in fact some sources say to do it to avoid repeating components (like https://www.youtube.com/watch?v=yH5Z-lSeV9Y ).
  // So IDK what the real guidance is for this and it seems to work fine.
  return (
    <GenericNameIdAutocomplete
      acText={acText || ''}
      setAcText={setAcText}
      acID={acID}
      setAcID={setAcID}
      setAutoBlurred={setAutoBlurred}
      supplyLookupList={supplyLookupList}
      nameFunc={nameFunc}
      idFunc={idFunc}
      controlOptions={controlOptions}
    />
  );
  /* eslint-enable react/jsx-no-bind */
}

RorAutocomplete.propTypes = {
  formRef: PropTypes.object.isRequired,
  acText: PropTypes.string.isRequired,
  setAcText: PropTypes.func.isRequired,
  acID: PropTypes.string.isRequired,
  setAcID: PropTypes.func.isRequired,
  controlOptions: PropTypes.object.isRequired,
};
