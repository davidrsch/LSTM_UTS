import 'cypress-file-upload';
import $ from 'jquery';
import _ from 'lodash';

Cypress.Commands.add('getDataFromDatatable', (datatableId) => {
  cy.get(`#${datatableId}`).then(($datatable) => {
    const data = [];

    // Extract header data (excluding the first `th`)
    $datatable.find('thead tr:first-child').each((index, row) => {
      const rowData = [];
      $(row).find('th').each((index, cell) => {
        rowData.push($(cell).text());
      });
      data.push(rowData);
    });

    // Extract tbody data
    $datatable.find('tbody tr').each((index, row) => {
      const rowData = [];
      $(row).find('td').each((index, cell) => {
        rowData.push($(cell).text());
      });
      data.push(rowData);
    });

    return JSON.stringify(data);
  });
});