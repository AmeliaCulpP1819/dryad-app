import React, {useState, useRef} from 'react';
import axios from 'axios';
import {Field, Form, Formik} from 'formik';
import PropTypes from 'prop-types';
import {showSavedMsg, showSavingMsg} from '../../../lib/utils';

function PrelimArticle() {
  const formRef = useRef();

  return (
      <Formik
          initialValues={
            {
              publication: 'great journal of testing',
              primary_article_doi: 'test'
            }
          }
          innerRef={formRef}
          onSubmit={(values, {setSubmitting}) => {
            // submitForm(values).then(() => { setSubmitting(false); });
          }}
      >
        {(formik) => (
            <Form className="c-input__inline">
              <div className="c-import__form-section">
                <p>Please provide the following information. You may either enter the information and leave it or choose
                  to
                  autofill your dataset based on the information you supply below.</p>

                <div className="c-input__inline">
                  <div className="c-input">
                    <label className="c-input__label required" htmlFor="publication">Journal Name</label>
                    <input className="c-input__text" type="text" name="publication" id="publication"/>>
                    <input type="hidden" name="publication_issn" id="publication_issn"/>
                    <input type="hidden" name="publication_name" id="publication_name"/>
                  </div>
                  <div className="c-input" style={{display: 'flex'}}>
                    <label className="c-input__label required" htmlFor="primary_article_doi">DOI</label>
                    <Field
                        className="c-input__text"
                        placeholder="5702.125/qlm.1266rr"
                        type="text"
                        name="primary_article_doi"
                        id="primary_article_doi"/>
                  </div>
                </div>
                <div>
                  <button type="submit" name="commit" className="o-button__import-manuscript">
                    Import Article Metadata
                  </button>
                </div>
                <div id="population-warnings" className="o-metadata__autopopulate-message">
                  Sample warning here.
                </div>
              </div>
            </Form>
        )}
      </Formik>
  );
}

export default PrelimArticle;