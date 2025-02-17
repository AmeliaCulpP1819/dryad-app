import React from "react";
import {render, screen, waitFor} from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import {faker} from '@faker-js/faker';
import AuthorForm from "../../../../../app/javascript/react/components/MetadataEntry/AuthorForm.js";
import axios from 'axios';

jest.mock('axios');

const makeAuthor = (resource_id = null, author_order = null) => {
  const sect = () => faker.datatype.number({min:1000, max:9999});
  return {
    author_first_name: faker.name.firstName(),
    author_last_name: faker.name.lastName(),
    author_email: faker.internet.email(),
    author_orcid: `${sect()}-${sect()}-${sect()}-${sect()}`,
    resource_id: resource_id || faker.datatype.number({min: 1, max: 32767}),
    author_order: author_order || faker.datatype.number({min: 1, max: 32767}),
    orcid_invite_path: faker.internet.url()
  };
}

describe('AuthorForm', () => {
  let dryadAuthor;
  beforeEach(() => {
    dryadAuthor = makeAuthor();
  });

  it("renders the basic author form", () => {
    render(<AuthorForm dryadAuthor={dryadAuthor} removeFunction={() => {}} correspondingAuthorId={27} />);

    const labeledElements = screen.getAllByLabelText('Institutional Affiliation', { exact: false });
    expect(labeledElements.length).toBe(2);

    expect(screen.getByLabelText('First Name')).toHaveValue(dryadAuthor.author_first_name);
    expect(screen.getByLabelText('Last Name')).toHaveValue(dryadAuthor.author_last_name);
    expect(screen.getByLabelText('Author Email')).toHaveValue(dryadAuthor.author_email);
  });

  // gives some pointers and info about act and async examples
  // https://javascript.plainenglish.io/you-probably-dont-need-act-in-your-react-tests-2a0bcd2ad65c
  it("checks that updating author triggers the save event and does axios call", async () => {

    const promise = Promise.resolve({
      status: 200,
      data: dryadAuthor
    });

    axios.patch.mockImplementationOnce(() => promise);

    render(<AuthorForm dryadAuthor={dryadAuthor} removeFunction={() => {}} correspondingAuthorId={27} />);

    userEvent.clear(screen.getByLabelText('First Name'));
    userEvent.type(screen.getByLabelText('First Name'), 'Alphred');

    await waitFor(() => expect(screen.getByLabelText('First Name')).toHaveValue('Alphred'));

    userEvent.tab(); // tab out of element, should trigger save on blur

    await waitFor(() => expect(screen.getByLabelText('Last Name')).toHaveFocus());
    await waitFor(() => promise); // waits for the axios promise to fulfil
    // This gives a warning when it runs in the console since we don't have the global JS items we use to display saving message
    // but it doesn't fail and test passes.
  })

});