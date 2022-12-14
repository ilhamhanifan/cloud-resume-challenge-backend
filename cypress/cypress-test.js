describe('api response status is 200', () => {
  it('GET', () => {
      cy.request('GET', 'https://crc-gw-id-2lcwykb8.an.gateway.dev/')
      .then((res) => {expect(res).to.have.property('status', 200)
      })
  })
})

describe('website response status is 200', () => {
  it('passes', () => {
    cy.request('GET','https://ilhamhanifan.dev')
      .then((res) => {expect(res.body).to.not.be.null}
    )
  })
})
