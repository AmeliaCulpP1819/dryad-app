import React from 'react';

const instructions = () => (
  <div>
    <p>
      You may upload data via two mechanisms: directly from your computer, or from a URL
      on an external server (e.g., Box, Dropbox, AWS, lab server). We do not recommend
      using Google Drive.
    </p>
    <p>
      We require that you include a <a href="/docs/README.md" target="_blank" rel="noreferrer">README.md</a> file based
      on our template in order to provide key
      information for understanding and reuse of your data.
    </p>
    <p>If you prefer, you can edit the Markdown online
      at <a href="https://hackmd.io/JgxUwkEdS9uOOcgadhe29w?both=" target="_blank" rel="noreferrer">hackmd.io</a>.
    </p>

    <ol>
      <li>Open the link (above)</li>
      <li>Copy and paste the text into a new note (create new by clicking the plus sign)</li>
      <li>When you&apos;re done, save into a README.md and upload the file under the <em>Data</em> category</li>
    </ol>

    <p>
      Software and Supplemental Information can be uploaded for publication
      at <a href="https://zenodo.org" target="_blank" rel="noreferrer">Zenodo</a>.
      You will have the opportunity to choose a separate license for your software on the review page.
    </p>
  </div>
);

export default instructions;
